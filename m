From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: deadlock on genl_mutex
Date: Thu, 8 Dec 2016 18:16:32 +0100
Message-ID: <CACT4Y+Zy82UAJ55VbPbVadUM92ZSx1VJCFPdhhcmj53uxZ5PXQ@mail.gmail.com>
References: <CACT4Y+ZdSNVhF2MH0=t=kBUrgNSSnCSO5uwnnc5c0KNLG+VNFQ@mail.gmail.com>
 <CANn89iJ1G4e655RnfcGK9RwmSSb2L=ZBSq9e2gpHVNmkUOYUxg@mail.gmail.com>
 <0227d7e83cc5ac0a192d1ba0fee61413@codeaurora.org> <CACT4Y+auHN0Rdu2Hepk6DNFmz1K2XSA6s18PC=KZiHdoMG845Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Florian Westphal <fw@strlen.de>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Richard Guy Briggs <rgb@redhat.com>,
        netdev-owner@vger.kernel.org
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+auHN0Rdu2Hepk6DNFmz1K2XSA6s18PC=KZiHdoMG845Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 8, 2016 at 5:16 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Tue, Nov 29, 2016 at 6:59 AM,  <subashab@codeaurora.org> wrote:
>>>
>>> Issue was reported yesterday and is under investigation.
>>>
>>>
>>> http://marc.info/?l=linux-netdev&m=148014004331663&w=2
>>>
>>>
>>> Thanks !
>>
>>
>> Hi Dmitry
>>
>> Can you try the patch below with your reproducer? I haven't seen similar
>> crashes reported after this (or even with Eric's patch).
>
> I've synced to 318c8932ddec5c1c26a4af0f3c053784841c598e (Dec 7) and do
> _not_ see this report happening anymore.
> Thanks.


But now I am seeing "possible deadlock" warnings involving genl_lock:

[ INFO: possible circular locking dependency detected ]
4.9.0-rc8+ #77 Not tainted
-------------------------------------------------------
syz-executor7/18794 is trying to acquire lock:
 (rtnl_mutex){+.+.+.}, at: [<ffffffff86b4682c>] rtnl_lock+0x1c/0x20
net/core/rtnetlink.c:70
but task is already holding lock:
 (genl_mutex){+.+.+.}, at: [<     inline     >] genl_lock
net/netlink/genetlink.c:31
 (genl_mutex){+.+.+.}, at: [<ffffffff86cc27c9>]
genl_rcv_msg+0x209/0x260 net/netlink/genetlink.c:658
which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

       [  315.403815] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2265
       [  315.403815] [<ffffffff81569576>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3338
       [  315.403815] [<ffffffff8156b672>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3749
       [  315.403815] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
       [  315.403815] [<ffffffff88195bcf>]
mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
       [  315.403815] [<     inline     >] genl_lock net/netlink/genetlink.c:31
       [  315.403815] [<ffffffff86cc0c26>] genl_lock_dumpit+0x46/0xa0
net/netlink/genetlink.c:518
       [  315.403815] [<ffffffff86cb33ac>] netlink_dump+0x57c/0xd70
net/netlink/af_netlink.c:2127
       [  315.403815] [<ffffffff86cb7b6a>]
__netlink_dump_start+0x4ea/0x760 net/netlink/af_netlink.c:2217
       [  315.403815] [<ffffffff86cc2319>]
genl_family_rcv_msg+0xdc9/0x1070 net/netlink/genetlink.c:586
       [  315.403815] [<ffffffff86cc2770>] genl_rcv_msg+0x1b0/0x260
net/netlink/genetlink.c:660
       [  315.403815] [<ffffffff86cc034c>] netlink_rcv_skb+0x2bc/0x3a0
net/netlink/af_netlink.c:2298
       [  315.403815] [<ffffffff86cc153d>] genl_rcv+0x2d/0x40
net/netlink/genetlink.c:671
       [  315.403815] [<     inline     >] netlink_unicast_kernel
net/netlink/af_netlink.c:1231
       [  315.403815] [<ffffffff86cbeb6a>] netlink_unicast+0x51a/0x740
net/netlink/af_netlink.c:1257
       [  315.403815] [<ffffffff86cbf834>] netlink_sendmsg+0xaa4/0xe50
net/netlink/af_netlink.c:1803
       [  315.403815] [<     inline     >] sock_sendmsg_nosec net/socket.c:621
       [  315.403815] [<ffffffff86a7618f>] sock_sendmsg+0xcf/0x110
net/socket.c:631
       [  315.403815] [<ffffffff86a764fb>] sock_write_iter+0x32b/0x620
net/socket.c:829
       [  315.403815] [<     inline     >] new_sync_write fs/read_write.c:499
       [  315.403815] [<ffffffff81a701ae>] __vfs_write+0x4fe/0x830
fs/read_write.c:512
       [  315.403815] [<ffffffff81a71c55>] vfs_write+0x175/0x4e0
fs/read_write.c:560
       [  315.403815] [<     inline     >] SYSC_write fs/read_write.c:607
       [  315.403815] [<ffffffff81a760e0>] SyS_write+0x100/0x240
fs/read_write.c:599
       [  315.403815] [<ffffffff881a5f85>] entry_SYSCALL_64_fastpath+0x23/0xc6

       [  315.403815] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2265
       [  315.403815] [<ffffffff81569576>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3338
       [  315.403815] [<ffffffff8156b672>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3749
       [  315.403815] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
       [  315.403815] [<ffffffff88195bcf>]
mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
       [  315.403815] [<ffffffff86cb7779>]
__netlink_dump_start+0xf9/0x760 net/netlink/af_netlink.c:2187
       [  315.403815] [<     inline     >] netlink_dump_start
include/linux/netlink.h:165
       [  315.403815] [<ffffffff86d14d48>]
ctnetlink_stat_ct_cpu+0x198/0x1e0
net/netfilter/nf_conntrack_netlink.c:2045
       [  315.403815] [<ffffffff86cd313e>]
nfnetlink_rcv_msg+0x9be/0xd60 net/netfilter/nfnetlink.c:212
       [  315.403815] [<ffffffff86cc034c>] netlink_rcv_skb+0x2bc/0x3a0
net/netlink/af_netlink.c:2298
       [  315.403815] [<ffffffff86cd1b71>] nfnetlink_rcv+0x7e1/0x10d0
net/netfilter/nfnetlink.c:474
       [  315.403815] [<     inline     >] netlink_unicast_kernel
net/netlink/af_netlink.c:1231
       [  315.403815] [<ffffffff86cbeb6a>] netlink_unicast+0x51a/0x740
net/netlink/af_netlink.c:1257
       [  315.403815] [<ffffffff86cbf834>] netlink_sendmsg+0xaa4/0xe50
net/netlink/af_netlink.c:1803
       [  315.403815] [<     inline     >] sock_sendmsg_nosec net/socket.c:621
       [  315.403815] [<ffffffff86a7618f>] sock_sendmsg+0xcf/0x110
net/socket.c:631
       [  315.403815] [<ffffffff86a764fb>] sock_write_iter+0x32b/0x620
net/socket.c:829
       [  315.403815] [<     inline     >] new_sync_write fs/read_write.c:499
       [  315.403815] [<ffffffff81a701ae>] __vfs_write+0x4fe/0x830
fs/read_write.c:512
       [  315.403815] [<ffffffff81a71c55>] vfs_write+0x175/0x4e0
fs/read_write.c:560
       [  315.403815] [<     inline     >] SYSC_write fs/read_write.c:607
       [  315.403815] [<ffffffff81a760e0>] SyS_write+0x100/0x240
fs/read_write.c:599
       [  315.403815] [<ffffffff881a5f85>] entry_SYSCALL_64_fastpath+0x23/0xc6

       [  315.403815] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2265
       [  315.403815] [<ffffffff81569576>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3338
       [  315.403815] [<ffffffff8156b672>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3749
       [  315.403815] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
       [  315.403815] [<ffffffff88195bcf>]
mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
       [  315.403815] [<ffffffff86cd083d>] nfnl_lock+0x2d/0x30
net/netfilter/nfnetlink.c:61
       [  315.403815] [<ffffffff86d7c5b1>]
nf_tables_netdev_event+0x1f1/0x720
net/netfilter/nf_tables_netdev.c:122
       [  315.403815] [<ffffffff8149095a>]
notifier_call_chain+0x14a/0x2f0 kernel/notifier.c:93
       [  315.403815] [<     inline     >] __raw_notifier_call_chain
kernel/notifier.c:394
       [  315.403815] [<ffffffff81490b82>]
raw_notifier_call_chain+0x32/0x40 kernel/notifier.c:401
       [  315.403815] [<ffffffff86ae4af6>]
call_netdevice_notifiers_info+0x56/0x90 net/core/dev.c:1645
       [  315.403815] [<     inline     >] call_netdevice_notifiers
net/core/dev.c:1661
       [  315.403815] [<ffffffff86af898d>]
rollback_registered_many+0x73d/0xba0 net/core/dev.c:6759
       [  315.403815] [<ffffffff86af8e9e>]
rollback_registered+0xae/0x100 net/core/dev.c:6800
       [  315.403815] [<ffffffff86af8f76>]
unregister_netdevice_queue+0x86/0x140 net/core/dev.c:7787
       [  315.403815] [<     inline     >] unregister_netdevice
include/linux/netdevice.h:2455
       [  315.403815] [<ffffffff84912be6>] __tun_detach+0xc66/0xea0
drivers/net/tun.c:567
       [  315.808015] [<     inline     >] tun_detach drivers/net/tun.c:578
       [  315.808015] [<ffffffff84912e69>] tun_chr_close+0x49/0x60
drivers/net/tun.c:2350
       [  315.808015] [<ffffffff81a77f7e>] __fput+0x34e/0x910
fs/file_table.c:208
       [  315.808015] [<ffffffff81a785ca>] ____fput+0x1a/0x20
fs/file_table.c:244
       [  315.808015] [<ffffffff81483c20>] task_work_run+0x1a0/0x280
kernel/task_work.c:116
       [  315.808015] [<     inline     >] exit_task_work
include/linux/task_work.h:21
       [  315.808015] [<ffffffff814129e2>] do_exit+0x1842/0x2650
kernel/exit.c:828
       [  315.808015] [<ffffffff814139ae>] do_group_exit+0x14e/0x420
kernel/exit.c:932
       [  315.808015] [<ffffffff81442b43>] get_signal+0x663/0x1880
kernel/signal.c:2307
       [  315.808015] [<ffffffff81239b45>] do_signal+0xc5/0x2190
arch/x86/kernel/signal.c:807
       [  315.808015] [<ffffffff8100666a>]
exit_to_usermode_loop+0x1ea/0x2d0 arch/x86/entry/common.c:156
       [  315.808015] [<     inline     >] prepare_exit_to_usermode
arch/x86/entry/common.c:190
       [  315.808015] [<ffffffff81009693>]
syscall_return_slowpath+0x4d3/0x570 arch/x86/entry/common.c:259
       [  315.808015] [<ffffffff881a6026>] entry_SYSCALL_64_fastpath+0xc4/0xc6

       [  315.808015] [<     inline     >] check_prev_add
kernel/locking/lockdep.c:1828
       [  315.808015] [<ffffffff8156309b>]
check_prevs_add+0xaab/0x1c20 kernel/locking/lockdep.c:1938
       [  315.808015] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2265
       [  315.808015] [<ffffffff81569576>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3338
       [  315.808015] [<ffffffff8156b672>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3749
       [  315.808015] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
       [  315.808015] [<ffffffff88195bcf>]
mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
       [  315.808015] [<ffffffff86b4682c>] rtnl_lock+0x1c/0x20
net/core/rtnetlink.c:70
       [  315.808015] [<ffffffff87b5cdf9>]
nl80211_pre_doit+0x309/0x5b0 net/wireless/nl80211.c:11750
       [  315.808015] [<ffffffff86cc1cd0>]
genl_family_rcv_msg+0x780/0x1070 net/netlink/genetlink.c:631
       [  315.808015] [<ffffffff86cc2770>] genl_rcv_msg+0x1b0/0x260
net/netlink/genetlink.c:660
       [  315.808015] [<ffffffff86cc034c>] netlink_rcv_skb+0x2bc/0x3a0
net/netlink/af_netlink.c:2298
       [  315.808015] [<ffffffff86cc153d>] genl_rcv+0x2d/0x40
net/netlink/genetlink.c:671
       [  315.808015] [<     inline     >] netlink_unicast_kernel
net/netlink/af_netlink.c:1231
       [  315.808015] [<ffffffff86cbeb6a>] netlink_unicast+0x51a/0x740
net/netlink/af_netlink.c:1257
       [  315.808015] [<ffffffff86cbf834>] netlink_sendmsg+0xaa4/0xe50
net/netlink/af_netlink.c:1803
       [  315.808015] [<     inline     >] sock_sendmsg_nosec net/socket.c:621
       [  315.808015] [<ffffffff86a7618f>] sock_sendmsg+0xcf/0x110
net/socket.c:631
       [  315.808015] [<ffffffff86a764fb>] sock_write_iter+0x32b/0x620
net/socket.c:829
       [  315.808015] [<ffffffff81a6f9a3>]
do_iter_readv_writev+0x363/0x670 fs/read_write.c:695
       [  315.808015] [<ffffffff81a723f1>] do_readv_writev+0x431/0x9b0
fs/read_write.c:872
       [  315.808015] [<ffffffff81a72f2c>] vfs_writev+0x8c/0xc0
fs/read_write.c:911
       [  315.808015] [<ffffffff81a73075>] do_writev+0x115/0x2d0
fs/read_write.c:944
       [  315.808015] [<     inline     >] SYSC_writev fs/read_write.c:1017
       [  315.808015] [<ffffffff81a7682c>] SyS_writev+0x2c/0x40
fs/read_write.c:1014
       [  315.808015] [<ffffffff881a5f85>] entry_SYSCALL_64_fastpath+0x23/0xc6

other info that might help us debug this:

Chain exists of:
 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(genl_mutex);
                               lock(nlk->cb_mutex);
                               lock(genl_mutex);
  lock(rtnl_mutex);

 *** DEADLOCK ***

2 locks held by syz-executor7/18794:
 #0:  (cb_lock){++++++}, at: [<ffffffff86cc152e>] genl_rcv+0x1e/0x40
net/netlink/genetlink.c:670
 #1:  (genl_mutex){+.+.+.}, at: [<     inline     >] genl_lock
net/netlink/genetlink.c:31
 #1:  (genl_mutex){+.+.+.}, at: [<ffffffff86cc27c9>]
genl_rcv_msg+0x209/0x260 net/netlink/genetlink.c:658

stack backtrace:
CPU: 0 PID: 18794 Comm: syz-executor7 Not tainted 4.9.0-rc8+ #77
Hardware name: Google Google/Google, BIOS Google 01/01/2011
 ffff88004add6468 ffffffff834c44f9 ffffffff00000000 1ffff100095bac20
 ffffed00095bac18 0000000041b58ab3 ffffffff895816f0 ffffffff834c420b
 0000000000000000 0000000000000000 0000000000000000 0000000000000000
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff834c44f9>] dump_stack+0x2ee/0x3f5 lib/dump_stack.c:51
 [<ffffffff81560cb0>] print_circular_bug+0x310/0x3c0
kernel/locking/lockdep.c:1202
 [<     inline     >] check_prev_add kernel/locking/lockdep.c:1828
 [<ffffffff8156309b>] check_prevs_add+0xaab/0x1c20 kernel/locking/lockdep.c:1938
 [<     inline     >] validate_chain kernel/locking/lockdep.c:2265
 [<ffffffff81569576>] __lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3338
 [<ffffffff8156b672>] lock_acquire+0x2a2/0x790 kernel/locking/lockdep.c:3749
 [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:521
 [<ffffffff88195bcf>] mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
 [<ffffffff86b4682c>] rtnl_lock+0x1c/0x20 net/core/rtnetlink.c:70
 [<ffffffff87b5cdf9>] nl80211_pre_doit+0x309/0x5b0 net/wireless/nl80211.c:11750
 [<ffffffff86cc1cd0>] genl_family_rcv_msg+0x780/0x1070
net/netlink/genetlink.c:631
 [<ffffffff86cc2770>] genl_rcv_msg+0x1b0/0x260 net/netlink/genetlink.c:660
 [<ffffffff86cc034c>] netlink_rcv_skb+0x2bc/0x3a0 net/netlink/af_netlink.c:2298
 [<ffffffff86cc153d>] genl_rcv+0x2d/0x40 net/netlink/genetlink.c:671
 [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1231
 [<ffffffff86cbeb6a>] netlink_unicast+0x51a/0x740 net/netlink/af_netlink.c:1257
 [<ffffffff86cbf834>] netlink_sendmsg+0xaa4/0xe50 net/netlink/af_netlink.c:1803
 [<     inline     >] sock_sendmsg_nosec net/socket.c:621
 [<ffffffff86a7618f>] sock_sendmsg+0xcf/0x110 net/socket.c:631
 [<ffffffff86a764fb>] sock_write_iter+0x32b/0x620 net/socket.c:829
 [<ffffffff81a6f9a3>] do_iter_readv_writev+0x363/0x670 fs/read_write.c:695
 [<ffffffff81a723f1>] do_readv_writev+0x431/0x9b0 fs/read_write.c:872
 [<ffffffff81a72f2c>] vfs_writev+0x8c/0xc0 fs/read_write.c:911
 [<ffffffff81a73075>] do_writev+0x115/0x2d0 fs/read_write.c:944
 [<     inline     >] SYSC_writev fs/read_write.c:1017
 [<ffffffff81a7682c>] SyS_writev+0x2c/0x40 fs/read_write.c:1014
 [<ffffffff881a5f85>] entry_SYSCALL_64_fastpath+0x23/0xc6
