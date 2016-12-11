From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: deadlock on genl_mutex
Date: Sun, 11 Dec 2016 10:40:54 +0100
Message-ID: <CACT4Y+Zsk0JABsBTyECbo3PYapihx3csQ4omVmeyG7Wx8z+nLA@mail.gmail.com>
References: <CACT4Y+ZdSNVhF2MH0=t=kBUrgNSSnCSO5uwnnc5c0KNLG+VNFQ@mail.gmail.com>
 <CANn89iJ1G4e655RnfcGK9RwmSSb2L=ZBSq9e2gpHVNmkUOYUxg@mail.gmail.com>
 <0227d7e83cc5ac0a192d1ba0fee61413@codeaurora.org> <CACT4Y+auHN0Rdu2Hepk6DNFmz1K2XSA6s18PC=KZiHdoMG845Q@mail.gmail.com>
 <CACT4Y+Zy82UAJ55VbPbVadUM92ZSx1VJCFPdhhcmj53uxZ5PXQ@mail.gmail.com>
 <CAM_iQpXxF_N+3VYRqjd4jySBbySPsZAAVVkNCBEXqc8gHJ6ZMQ@mail.gmail.com> <CAM_iQpW2x5xeBpxnZx+k+vnKkjxWPycCBpiKZE41Kcp5gBsN4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        Florian Westphal <fw@strlen.de>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Richard Guy Briggs <rgb@redhat.com>,
        netdev-owner@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpW2x5xeBpxnZx+k+vnKkjxWPycCBpiKZE41Kcp5gBsN4w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 9, 2016 at 6:08 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Dec 8, 2016 at 4:32 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Thu, Dec 8, 2016 at 9:16 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>> Chain exists of:
>>>  Possible unsafe locking scenario:
>>>
>>>        CPU0                    CPU1
>>>        ----                    ----
>>>   lock(genl_mutex);
>>>                                lock(nlk->cb_mutex);
>>>                                lock(genl_mutex);
>>>   lock(rtnl_mutex);
>>>
>>>  *** DEADLOCK ***
>>
>> This one looks legitimate, because nlk->cb_mutex could be rtnl_mutex.
>> Let me think about it.
>
> Never mind. Actually both reports in this thread are legitimate.
>
> I know what happened now, the lock chain is so long, 4 locks are involved
> to form a chain!!!
>
> Let me think about how to break the chain.



Seems to be a related one, now on nfnl_lock :



[ INFO: possible circular locking dependency detected ]
4.9.0-rc8+ #82 Not tainted
-------------------------------------------------------
syz-executor3/10151 is trying to acquire lock:
 (&table[i].mutex){+.+.+.}, at: [<ffffffff86c96f1d>]
nfnl_lock+0x2d/0x30 net/netfilter/nfnetlink.c:61
but task is already holding lock:
 (rtnl_mutex){+.+.+.}, at: [<ffffffff86b0cf0c>] rtnl_lock+0x1c/0x20
net/core/rtnetlink.c:70
which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

       [  231.942041] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2265
       [  231.942041] [<ffffffff81569576>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3338
floppy0: disk absent or changed during operation
floppy0: disk absent or changed during operation
       [  231.950342] [<ffffffff8156b672>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3749
       [  231.950342] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
       [  231.950342] [<ffffffff8815c2bf>]
mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
       [  231.950342] [<ffffffff86b0cf0c>] rtnl_lock+0x1c/0x20
net/core/rtnetlink.c:70
       [  231.950342] [<ffffffff87b234e9>]
nl80211_pre_doit+0x309/0x5b0 net/wireless/nl80211.c:11750
       [  231.950342] [<ffffffff86c883b0>]
genl_family_rcv_msg+0x780/0x1070 net/netlink/genetlink.c:631
       [  231.950342] [<ffffffff86c88e50>] genl_rcv_msg+0x1b0/0x260
net/netlink/genetlink.c:660
       [  231.950342] [<ffffffff86c86a2c>] netlink_rcv_skb+0x2bc/0x3a0
net/netlink/af_netlink.c:2298
       [  231.950342] [<ffffffff86c87c1d>] genl_rcv+0x2d/0x40
net/netlink/genetlink.c:671
       [  231.950342] [<     inline     >] netlink_unicast_kernel
net/netlink/af_netlink.c:1231
       [  231.950342] [<ffffffff86c8524a>] netlink_unicast+0x51a/0x740
net/netlink/af_netlink.c:1257
       [  231.950342] [<ffffffff86c85f14>] netlink_sendmsg+0xaa4/0xe50
net/netlink/af_netlink.c:1803
       [  231.950342] [<     inline     >] sock_sendmsg_nosec net/socket.c:621
       [  231.950342] [<ffffffff86a3c86f>] sock_sendmsg+0xcf/0x110
net/socket.c:631
       [  231.950342] [<ffffffff86a3cbdb>] sock_write_iter+0x32b/0x620
net/socket.c:829
       [  231.950342] [<     inline     >] new_sync_write fs/read_write.c:499
       [  231.950342] [<ffffffff81a7021e>] __vfs_write+0x4fe/0x830
fs/read_write.c:512
       [  231.950342] [<ffffffff81a71cc5>] vfs_write+0x175/0x4e0
fs/read_write.c:560
       [  231.950342] [<     inline     >] SYSC_write fs/read_write.c:607
       [  231.950342] [<ffffffff81a76150>] SyS_write+0x100/0x240
fs/read_write.c:599
       [  231.950342] [<ffffffff8816c685>] entry_SYSCALL_64_fastpath+0x23/0xc6

       [  231.950342] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2265
       [  231.950342] [<ffffffff81569576>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3338
       [  231.950342] [<ffffffff8156b672>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3749
       [  231.950342] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
       [  231.950342] [<ffffffff8815c2bf>]
mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
       [  231.950342] [<     inline     >] genl_lock net/netlink/genetlink.c:31
       [  231.950342] [<ffffffff86c87306>] genl_lock_dumpit+0x46/0xa0
net/netlink/genetlink.c:518
       [  231.950342] [<ffffffff86c79a8c>] netlink_dump+0x57c/0xd70
net/netlink/af_netlink.c:2127
       [  231.950342] [<ffffffff86c7e24a>]
__netlink_dump_start+0x4ea/0x760 net/netlink/af_netlink.c:2217
       [  231.950342] [<ffffffff86c889f9>]
genl_family_rcv_msg+0xdc9/0x1070 net/netlink/genetlink.c:586
       [  231.950342] [<ffffffff86c88e50>] genl_rcv_msg+0x1b0/0x260
net/netlink/genetlink.c:660
       [  231.950342] [<ffffffff86c86a2c>] netlink_rcv_skb+0x2bc/0x3a0
net/netlink/af_netlink.c:2298
       [  231.950342] [<ffffffff86c87c1d>] genl_rcv+0x2d/0x40
net/netlink/genetlink.c:671
       [  231.950342] [<     inline     >] netlink_unicast_kernel
net/netlink/af_netlink.c:1231
       [  231.950342] [<ffffffff86c8524a>] netlink_unicast+0x51a/0x740
net/netlink/af_netlink.c:1257
       [  231.950342] [<ffffffff86c85f14>] netlink_sendmsg+0xaa4/0xe50
net/netlink/af_netlink.c:1803
       [  231.950342] [<     inline     >] sock_sendmsg_nosec net/socket.c:621
       [  231.950342] [<ffffffff86a3c86f>] sock_sendmsg+0xcf/0x110
net/socket.c:631
       [  231.950342] [<ffffffff86a3cbdb>] sock_write_iter+0x32b/0x620
net/socket.c:829
       [  231.950342] [<ffffffff81a6fa13>]
do_iter_readv_writev+0x363/0x670 fs/read_write.c:695
       [  231.950342] [<ffffffff81a72461>] do_readv_writev+0x431/0x9b0
fs/read_write.c:872
       [  231.950342] [<ffffffff81a72f9c>] vfs_writev+0x8c/0xc0
fs/read_write.c:911
       [  231.950342] [<ffffffff81a730e5>] do_writev+0x115/0x2d0
fs/read_write.c:944
       [  231.950342] [<     inline     >] SYSC_writev fs/read_write.c:1017
       [  231.950342] [<ffffffff81a7689c>] SyS_writev+0x2c/0x40
fs/read_write.c:1014
       [  231.950342] [<ffffffff8816c685>] entry_SYSCALL_64_fastpath+0x23/0xc6

       [  231.950342] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2265
       [  231.950342] [<ffffffff81569576>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3338
       [  231.950342] [<ffffffff8156b672>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3749
       [  231.950342] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
       [  231.950342] [<ffffffff8815c2bf>]
mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
       [  231.950342] [<ffffffff86c7de59>]
__netlink_dump_start+0xf9/0x760 net/netlink/af_netlink.c:2187
       [  231.950342] [<     inline     >] netlink_dump_start
include/linux/netlink.h:165
       [  231.950342] [<ffffffff86d9d964>] ip_set_dump+0x204/0x2b0
net/netfilter/ipset/ip_set_core.c:1447
       [  231.950342] [<ffffffff86c9981e>]
nfnetlink_rcv_msg+0x9be/0xd60 net/netfilter/nfnetlink.c:212
       [  231.950342] [<ffffffff86c86a2c>] netlink_rcv_skb+0x2bc/0x3a0
net/netlink/af_netlink.c:2298
       [  231.950342] [<ffffffff86c98251>] nfnetlink_rcv+0x7e1/0x10d0
net/netfilter/nfnetlink.c:474
       [  231.950342] [<     inline     >] netlink_unicast_kernel
net/netlink/af_netlink.c:1231
       [  231.950342] [<ffffffff86c8524a>] netlink_unicast+0x51a/0x740
net/netlink/af_netlink.c:1257
       [  231.950342] [<ffffffff86c85f14>] netlink_sendmsg+0xaa4/0xe50
net/netlink/af_netlink.c:1803
       [  231.950342] [<     inline     >] sock_sendmsg_nosec net/socket.c:621
       [  231.950342] [<ffffffff86a3c86f>] sock_sendmsg+0xcf/0x110
net/socket.c:631
       [  231.950342] [<ffffffff86a3cbdb>] sock_write_iter+0x32b/0x620
net/socket.c:829
       [  231.950342] [<     inline     >] new_sync_write fs/read_write.c:499
       [  231.950342] [<ffffffff81a7021e>] __vfs_write+0x4fe/0x830
fs/read_write.c:512
       [  231.950342] [<ffffffff81a71cc5>] vfs_write+0x175/0x4e0
fs/read_write.c:560
       [  231.950342] [<     inline     >] SYSC_write fs/read_write.c:607
       [  231.950342] [<ffffffff81a76150>] SyS_write+0x100/0x240
fs/read_write.c:599
       [  231.950342] [<ffffffff8816c685>] entry_SYSCALL_64_fastpath+0x23/0xc6

       [  231.950342] [<     inline     >] check_prev_add
kernel/locking/lockdep.c:1828
       [  231.950342] [<ffffffff8156309b>]
check_prevs_add+0xaab/0x1c20 kernel/locking/lockdep.c:1938
       [  231.950342] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2265
       [  231.950342] [<ffffffff81569576>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3338
       [  231.950342] [<ffffffff8156b672>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3749
       [  231.950342] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
       [  231.950342] [<ffffffff8815c2bf>]
mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
       [  231.950342] [<ffffffff86c96f1d>] nfnl_lock+0x2d/0x30
net/netfilter/nfnetlink.c:61
       [  231.950342] [<ffffffff86d42c91>]
nf_tables_netdev_event+0x1f1/0x720
net/netfilter/nf_tables_netdev.c:122
       [  231.950342] [<ffffffff8149095a>]
notifier_call_chain+0x14a/0x2f0 kernel/notifier.c:93
       [  231.950342] [<     inline     >] __raw_notifier_call_chain
kernel/notifier.c:394
       [  231.950342] [<ffffffff81490b82>]
raw_notifier_call_chain+0x32/0x40 kernel/notifier.c:401
       [  231.950342] [<ffffffff86aab1d6>]
call_netdevice_notifiers_info+0x56/0x90 net/core/dev.c:1645
       [  231.950342] [<     inline     >] call_netdevice_notifiers
net/core/dev.c:1661
       [  231.950342] [<ffffffff86abf06d>]
rollback_registered_many+0x73d/0xba0 net/core/dev.c:6759
       [  231.950342] [<ffffffff86abf57e>]
rollback_registered+0xae/0x100 net/core/dev.c:6800
       [  231.950342] [<ffffffff86abf656>]
unregister_netdevice_queue+0x86/0x140 net/core/dev.c:7787
       [  231.950342] [<     inline     >] unregister_netdevice
include/linux/netdevice.h:2455
       [  231.950342] [<ffffffff848d9296>] __tun_detach+0xc66/0xea0
drivers/net/tun.c:567
       [  231.950342] [<     inline     >] tun_detach drivers/net/tun.c:578
       [  231.950342] [<ffffffff848d9519>] tun_chr_close+0x49/0x60
drivers/net/tun.c:2350
       [  231.950342] [<ffffffff81a77fee>] __fput+0x34e/0x910
fs/file_table.c:208
       [  231.950342] [<ffffffff81a7863a>] ____fput+0x1a/0x20
fs/file_table.c:244
       [  231.950342] [<ffffffff81483c20>] task_work_run+0x1a0/0x280
kernel/task_work.c:116
       [  231.950342] [<     inline     >] exit_task_work
include/linux/task_work.h:21
       [  231.950342] [<ffffffff814129e2>] do_exit+0x1842/0x2650
kernel/exit.c:828
       [  231.950342] [<ffffffff814139ae>] do_group_exit+0x14e/0x420
kernel/exit.c:932
       [  231.950342] [<ffffffff81442b43>] get_signal+0x663/0x1880
kernel/signal.c:2307
       [  231.950342] [<ffffffff81239b45>] do_signal+0xc5/0x2190
arch/x86/kernel/signal.c:807
       [  231.950342] [<ffffffff8100666a>]
exit_to_usermode_loop+0x1ea/0x2d0 arch/x86/entry/common.c:156
       [  231.950342] [<     inline     >] prepare_exit_to_usermode
arch/x86/entry/common.c:190
       [  231.950342] [<ffffffff81009693>]
syscall_return_slowpath+0x4d3/0x570 arch/x86/entry/common.c:259
       [  231.950342] [<ffffffff8816c726>] entry_SYSCALL_64_fastpath+0xc4/0xc6

other info that might help us debug this:

Chain exists of:
 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(rtnl_mutex);
                               lock(genl_mutex);
                               lock(rtnl_mutex);
  lock(&table[i].mutex);

 *** DEADLOCK ***

1 lock held by syz-executor3/10151:
 #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff86b0cf0c>]
rtnl_lock+0x1c/0x20 net/core/rtnetlink.c:70

stack backtrace:
CPU: 2 PID: 10151 Comm: syz-executor3 Not tainted 4.9.0-rc8+ #82
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff8800311057f8 ffffffff8348fc59 ffffffff00000002 1ffff10006220a92
 ffffed0006220a8a 0000000041b58ab3 ffffffff8957cf18 ffffffff8348f96b
 ffffffff894eb258 ffffffff81564970 ffffffff8b565c30 ffffffff8b8e5020
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff8348fc59>] dump_stack+0x2ee/0x3f5 lib/dump_stack.c:51
 [<ffffffff81560cb0>] print_circular_bug+0x310/0x3c0
kernel/locking/lockdep.c:1202
 [<     inline     >] check_prev_add kernel/locking/lockdep.c:1828
 [<ffffffff8156309b>] check_prevs_add+0xaab/0x1c20 kernel/locking/lockdep.c:1938
 [<     inline     >] validate_chain kernel/locking/lockdep.c:2265
 [<ffffffff81569576>] __lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3338
 [<ffffffff8156b672>] lock_acquire+0x2a2/0x790 kernel/locking/lockdep.c:3749
 [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:521
 [<ffffffff8815c2bf>] mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
 [<ffffffff86c96f1d>] nfnl_lock+0x2d/0x30 net/netfilter/nfnetlink.c:61
 [<ffffffff86d42c91>] nf_tables_netdev_event+0x1f1/0x720
net/netfilter/nf_tables_netdev.c:122
 [<ffffffff8149095a>] notifier_call_chain+0x14a/0x2f0 kernel/notifier.c:93
 [<     inline     >] __raw_notifier_call_chain kernel/notifier.c:394
 [<ffffffff81490b82>] raw_notifier_call_chain+0x32/0x40 kernel/notifier.c:401
 [<ffffffff86aab1d6>] call_netdevice_notifiers_info+0x56/0x90
net/core/dev.c:1645
 [<     inline     >] call_netdevice_notifiers net/core/dev.c:1661
 [<ffffffff86abf06d>] rollback_registered_many+0x73d/0xba0 net/core/dev.c:6759
 [<ffffffff86abf57e>] rollback_registered+0xae/0x100 net/core/dev.c:6800
 [<ffffffff86abf656>] unregister_netdevice_queue+0x86/0x140 net/core/dev.c:7787
 [<     inline     >] unregister_netdevice include/linux/netdevice.h:2455
 [<ffffffff848d9296>] __tun_detach+0xc66/0xea0 drivers/net/tun.c:567
 [<     inline     >] tun_detach drivers/net/tun.c:578
 [<ffffffff848d9519>] tun_chr_close+0x49/0x60 drivers/net/tun.c:2350
 [<ffffffff81a77fee>] __fput+0x34e/0x910 fs/file_table.c:208
 [<ffffffff81a7863a>] ____fput+0x1a/0x20 fs/file_table.c:244
 [<ffffffff81483c20>] task_work_run+0x1a0/0x280 kernel/task_work.c:116
 [<     inline     >] exit_task_work include/linux/task_work.h:21
 [<ffffffff814129e2>] do_exit+0x1842/0x2650 kernel/exit.c:828
 [<ffffffff814139ae>] do_group_exit+0x14e/0x420 kernel/exit.c:932
 [<ffffffff81442b43>] get_signal+0x663/0x1880 kernel/signal.c:2307
 [<ffffffff81239b45>] do_signal+0xc5/0x2190 arch/x86/kernel/signal.c:807
 [<ffffffff8100666a>] exit_to_usermode_loop+0x1ea/0x2d0
arch/x86/entry/common.c:156
 [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
 [<ffffffff81009693>] syscall_return_slowpath+0x4d3/0x570
arch/x86/entry/common.c:259
 [<ffffffff8816c726>] entry_SYSCALL_64_fastpath+0xc4/0xc6
