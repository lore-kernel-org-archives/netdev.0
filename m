From: dingtianhong <dingtianhong@huawei.com>
Subject: [BUG REPORT] ipv6: possible unsafe locking scenario
Date: Wed, 8 May 2013 12:44:38 +0800
Message-ID: <5189D836.3060903@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:48217 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815Ab3EHEpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 00:45:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi =EF=BC=81
I make the kernel config with CONFIG_PROVE_LOCKING CONFIG_IOSCHED_CFQ C=
ONFIG_PREEMPT_RT_FULL on,
and do several test case, it works well, but i notice that the log mess=
age has some Call Trace for rwlock,
it happens only once, maybe the lock use is not safe in ipv6 and need t=
o improve.

        CPU0                    CPU1
        ----                    ----
   lock(&mc->mca_lock);
                                lock(&ndev->lock);
                                lock(&mc->mca_lock);
   lock(&ndev->lock);

the kernel version is 3.4.24
the test case include LSB.
the problem has report to bugzilla:
https://bugzilla.kernel.org/show_bug.cgi?id=3D57691&GoAheadAndLogIn=3D1

following the message:
linux kernel: [ 5913.077146]=20
Apr 20 11:01:28 euler-linux kernel: [ 5913.077149] =3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Apr 20 11:01:28 euler-linux kernel: [ 5913.077150] [ INFO: possible cir=
cular locking dependency detected ]
Apr 20 11:01:28 euler-linux kernel: [ 5913.077154] 3.4.24.05-0.1-defaul=
t #1 Not tainted
Apr 20 11:01:28 euler-linux kernel: [ 5913.077155] --------------------=
-----------------------------------
Apr 20 11:01:28 euler-linux kernel: [ 5913.077157] ksoftirqd/0/3 is try=
ing to acquire lock:
Apr 20 11:01:28 euler-linux kernel: [ 5913.077158]  (&ndev->lock){+.+..=
=2E}, at: [<ffffffff8147f804>] ipv6_get_lladdr+0x74/0x120
Apr 20 11:01:28 euler-linux kernel: [ 5913.077168]=20
Apr 20 11:01:28 euler-linux kernel: [ 5913.077169] but task is already =
holding lock:
Apr 20 11:01:28 euler-linux kernel: [ 5913.077170]  (&mc->mca_lock){+.+=
=2E..}, at: [<ffffffff8149d130>] mld_send_report+0x40/0x150
Apr 20 11:01:28 euler-linux kernel: [ 5913.077177]=20
Apr 20 11:01:28 euler-linux kernel: [ 5913.077177] which lock already d=
epends on the new lock.
Apr 20 11:01:28 euler-linux kernel: [ 5913.077178]=20
Apr 20 11:01:28 euler-linux kernel: [ 5913.077179]=20
Apr 20 11:01:28 euler-linux kernel: [ 5913.077179] the existing depende=
ncy chain (in reverse order) is:
Apr 20 11:01:28 euler-linux kernel: [ 5913.077181]=20
Apr 20 11:01:28 euler-linux kernel: [ 5913.077182] -> #1 (&mc->mca_lock=
){+.+...}:
Apr 20 11:01:28 euler-linux kernel: [ 5913.077184]        [<ffffffff810=
a8027>] validate_chain+0x637/0x730
Apr 20 11:01:28 euler-linux kernel: [ 5913.077191]        [<ffffffff810=
a8417>] __lock_acquire+0x2f7/0x500
Apr 20 11:01:28 euler-linux kernel: [ 5913.077195]        [<ffffffff810=
a8734>] lock_acquire+0x114/0x150
Apr 20 11:01:28 euler-linux kernel: [ 5913.077198]        [<ffffffff814=
f691a>] rt_spin_lock+0x4a/0x60
Apr 20 11:01:28 euler-linux kernel: [ 5913.077203]        [<ffffffff814=
9e4bb>] igmp6_group_added+0x3b/0x120
Apr 20 11:01:28 euler-linux kernel: [ 5913.077206]        [<ffffffff814=
9e5d8>] ipv6_mc_up+0x38/0x60
Apr 20 11:01:28 euler-linux kernel: [ 5913.077209]        [<ffffffff814=
80a4d>] ipv6_find_idev+0x3d/0x80
Apr 20 11:01:28 euler-linux kernel: [ 5913.077212]        [<ffffffff814=
83175>] addrconf_notify+0x3d5/0x4b0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077215]        [<ffffffff814=
fae3f>] notifier_call_chain+0x3f/0x80
Apr 20 11:01:28 euler-linux kernel: [ 5913.077218]        [<ffffffff810=
73471>] raw_notifier_call_chain+0x11/0x20
Apr 20 11:01:28 euler-linux kernel: [ 5913.077224]        [<ffffffff813=
d8722>] call_netdevice_notifiers+0x32/0x60
Apr 20 11:01:28 euler-linux kernel: [ 5913.077230]        [<ffffffff813=
d92d4>] __dev_notify_flags+0x34/0x80
Apr 20 11:01:28 euler-linux kernel: [ 5913.077233]        [<ffffffff813=
d9360>] dev_change_flags+0x40/0x70
Apr 20 11:01:28 euler-linux kernel: [ 5913.077236]        [<ffffffff813=
ea627>] do_setlink+0x237/0x8a0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077240]        [<ffffffff813=
ebb6c>] rtnl_newlink+0x3ec/0x600
Apr 20 11:01:28 euler-linux kernel: [ 5913.077243]        [<ffffffff813=
eb4d0>] rtnetlink_rcv_msg+0x160/0x310
Apr 20 11:01:28 euler-linux kernel: [ 5913.077246]        [<ffffffff814=
040b9>] netlink_rcv_skb+0x89/0xb0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077251]        [<ffffffff813=
eb357>] rtnetlink_rcv+0x27/0x40
Apr 20 11:01:28 euler-linux kernel: [ 5913.077254]        [<ffffffff814=
03e20>] netlink_unicast+0x140/0x180
Apr 20 11:01:28 euler-linux kernel: [ 5913.077257]        [<ffffffff814=
04a9e>] netlink_sendmsg+0x33e/0x380
Apr 20 11:01:28 euler-linux kernel: [ 5913.077260]        [<ffffffff813=
c4252>] sock_sendmsg+0x112/0x130
Apr 20 11:01:28 euler-linux kernel: [ 5913.077264]        [<ffffffff813=
c537e>] __sys_sendmsg+0x44e/0x460
Apr 20 11:01:28 euler-linux kernel: [ 5913.077267]        [<ffffffff813=
c5544>] sys_sendmsg+0x44/0x70
Apr 20 11:01:28 euler-linux kernel: [ 5913.077269]        [<ffffffff814=
feab9>] system_call_fastpath+0x16/0x1b
Apr 20 11:01:28 euler-linux kernel: [ 5913.077273]=20
Apr 20 11:01:28 euler-linux kernel: [ 5913.077273] -> #0 (&ndev->lock){=
+.+...}:
Apr 20 11:01:28 euler-linux kernel: [ 5913.077275]        [<ffffffff810=
a798e>] check_prev_add+0x3de/0x440
Apr 20 11:01:28 euler-linux kernel: [ 5913.077278]        [<ffffffff810=
a8027>] validate_chain+0x637/0x730
Apr 20 11:01:28 euler-linux kernel: [ 5913.077281]        [<ffffffff810=
a8417>] __lock_acquire+0x2f7/0x500
Apr 20 11:01:28 euler-linux kernel: [ 5913.077284]        [<ffffffff810=
a8734>] lock_acquire+0x114/0x150
Apr 20 11:01:28 euler-linux kernel: [ 5913.077287]        [<ffffffff814=
f6c82>] rt_read_lock+0x42/0x60
Apr 20 11:01:28 euler-linux kernel: [ 5913.077290]        [<ffffffff814=
7f804>] ipv6_get_lladdr+0x74/0x120
Apr 20 11:01:28 euler-linux kernel: [ 5913.077293]        [<ffffffff814=
9b036>] mld_newpack+0xb6/0x160
Apr 20 11:01:28 euler-linux kernel: [ 5913.077295]        [<ffffffff814=
9b18b>] add_grhead+0xab/0xc0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077298]        [<ffffffff814=
9d03b>] add_grec+0x3ab/0x460
Apr 20 11:01:28 euler-linux kernel: [ 5913.077301]        [<ffffffff814=
9d14a>] mld_send_report+0x5a/0x150
Apr 20 11:01:28 euler-linux kernel: [ 5913.077304]        [<ffffffff814=
9f99e>] igmp6_timer_handler+0x4e/0xb0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077307]        [<ffffffff810=
5705a>] call_timer_fn+0xca/0x1d0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077312]        [<ffffffff810=
57b9f>] run_timer_softirq+0x1df/0x2e0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077315]        [<ffffffff810=
4e8c7>] handle_pending_softirqs+0xf7/0x1f0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077318]        [<ffffffff810=
4ea3b>] __do_softirq_common+0x7b/0xf0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077320]        [<ffffffff810=
4f07f>] __thread_do_softirq+0x1af/0x210
Apr 20 11:01:28 euler-linux kernel: [ 5913.077323]        [<ffffffff810=
4f1c1>] run_ksoftirqd+0xe1/0x1f0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077325]        [<ffffffff810=
6c7de>] kthread+0xae/0xc0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077327]        [<ffffffff814=
fff74>] kernel_thread_helper+0x4/0x10
Apr 20 11:01:28 euler-linux kernel: [ 5913.077332]=20
Apr 20 11:01:28 euler-linux kernel: [ 5913.077332] other info that migh=
t help us debug this:
Apr 20 11:01:28 euler-linux kernel: [ 5913.077333]=20
Apr 20 11:01:28 euler-linux kernel: [ 5913.077334]  Possible unsafe loc=
king scenario:
Apr 20 11:01:28 euler-linux kernel: [ 5913.077335]=20
Apr 20 11:01:28 euler-linux kernel: [ 5913.077336]        CPU0         =
           CPU1
Apr 20 11:01:28 euler-linux kernel: [ 5913.077337]        ----         =
           ----
Apr 20 11:01:28 euler-linux kernel: [ 5913.077338]   lock(&mc->mca_lock=
);
Apr 20 11:01:28 euler-linux kernel: [ 5913.077339]                     =
           lock(&ndev->lock);
Apr 20 11:01:28 euler-linux kernel: [ 5913.077341]                     =
           lock(&mc->mca_lock);
Apr 20 11:01:28 euler-linux kernel: [ 5913.077342]   lock(&ndev->lock);
Apr 20 11:01:28 euler-linux kernel: [ 5913.077344]=20
Apr 20 11:01:28 euler-linux kernel: [ 5913.077344]  *** DEADLOCK ***
Apr 20 11:01:28 euler-linux kernel: [ 5913.077345]=20
Apr 20 11:01:28 euler-linux kernel: [ 5913.077346] 4 locks held by ksof=
tirqd/0/3:
Apr 20 11:01:28 euler-linux kernel: [ 5913.077347]  #0:  (&per_cpu(loca=
l_softirq_lock, __cpu).lock){+.+.+.}, at: [<ffffffff8104ef5e>] __thread=
_do_softirq+0x8e/0x210
Apr 20 11:01:28 euler-linux kernel: [ 5913.077351]  #1:  (&mc->mca_time=
r){+.+...}, at: [<ffffffff81056f90>] call_timer_fn+0x0/0x1d0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077355]  #2:  (&mc->mca_lock=
){+.+...}, at: [<ffffffff8149d130>] mld_send_report+0x40/0x150
Apr 20 11:01:28 euler-linux kernel: [ 5913.077359]  #3:  (rcu_read_lock=
){.+.+.+}, at: [<ffffffff8147f790>] ipv6_get_lladdr+0x0/0x120
Apr 20 11:01:28 euler-linux kernel: [ 5913.077363]=20
Apr 20 11:01:28 euler-linux kernel: [ 5913.077363] stack backtrace:
Apr 20 11:01:28 euler-linux kernel: [ 5913.077365] Pid: 3, comm: ksofti=
rqd/0 Not tainted 3.4.24.05-0.1-default #1
Apr 20 11:01:28 euler-linux kernel: [ 5913.077367] Call Trace:
Apr 20 11:01:28 euler-linux kernel: [ 5913.077371]  [<ffffffff810a5abf>=
] print_circular_bug+0x10f/0x120
Apr 20 11:01:28 euler-linux kernel: [ 5913.077375]  [<ffffffff810a798e>=
] check_prev_add+0x3de/0x440
Apr 20 11:01:28 euler-linux kernel: [ 5913.077378]  [<ffffffff810a8027>=
] validate_chain+0x637/0x730
Apr 20 11:01:28 euler-linux kernel: [ 5913.077381]  [<ffffffff810a8417>=
] __lock_acquire+0x2f7/0x500
Apr 20 11:01:28 euler-linux kernel: [ 5913.077385]  [<ffffffff810a8734>=
] lock_acquire+0x114/0x150
Apr 20 11:01:28 euler-linux kernel: [ 5913.077387]  [<ffffffff8147f804>=
] ? ipv6_get_lladdr+0x74/0x120
Apr 20 11:01:28 euler-linux kernel: [ 5913.077391]  [<ffffffff8107a5a1>=
] ? get_parent_ip+0x11/0x50
Apr 20 11:01:28 euler-linux kernel: [ 5913.077394]  [<ffffffff814f6c82>=
] rt_read_lock+0x42/0x60
Apr 20 11:01:28 euler-linux kernel: [ 5913.077396]  [<ffffffff8147f804>=
] ? ipv6_get_lladdr+0x74/0x120
Apr 20 11:01:28 euler-linux kernel: [ 5913.077399]  [<ffffffff8147f804>=
] ipv6_get_lladdr+0x74/0x120
Apr 20 11:01:28 euler-linux kernel: [ 5913.077401]  [<ffffffff8147f790>=
] ? if6_seq_start+0x100/0x100
Apr 20 11:01:28 euler-linux kernel: [ 5913.077404]  [<ffffffff8149b036>=
] mld_newpack+0xb6/0x160
Apr 20 11:01:28 euler-linux kernel: [ 5913.077407]  [<ffffffff810a8417>=
] ? __lock_acquire+0x2f7/0x500
Apr 20 11:01:28 euler-linux kernel: [ 5913.077410]  [<ffffffff8149b18b>=
] add_grhead+0xab/0xc0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077413]  [<ffffffff8149d03b>=
] add_grec+0x3ab/0x460
Apr 20 11:01:28 euler-linux kernel: [ 5913.077416]  [<ffffffff8149f950>=
] ? ipv6_mc_destroy_dev+0xd0/0xd0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077419]  [<ffffffff8149d14a>=
] mld_send_report+0x5a/0x150
Apr 20 11:01:28 euler-linux kernel: [ 5913.077422]  [<ffffffff8149f99e>=
] igmp6_timer_handler+0x4e/0xb0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077425]  [<ffffffff8105705a>=
] call_timer_fn+0xca/0x1d0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077427]  [<ffffffff81056f90>=
] ? del_timer+0x130/0x130
Apr 20 11:01:28 euler-linux kernel: [ 5913.077431]  [<ffffffff8149f950>=
] ? ipv6_mc_destroy_dev+0xd0/0xd0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077434]  [<ffffffff81057b9f>=
] run_timer_softirq+0x1df/0x2e0
Apr 20 11:01:28 euler-linux kernel: [ 5913.077437]  [<ffffffff8104e8c7>=
] handle_pending_softirqs+0xf7/0x1f0
Apr 20 11:01:29 euler-linux kernel: [ 5913.077439]  [<ffffffff8104ea3b>=
] __do_softirq_common+0x7b/0xf0
Apr 20 11:01:29 euler-linux kernel: [ 5913.077442]  [<ffffffff8104f07f>=
] __thread_do_softirq+0x1af/0x210
Apr 20 11:01:29 euler-linux kernel: [ 5913.077444]  [<ffffffff8104f1c1>=
] run_ksoftirqd+0xe1/0x1f0
Apr 20 11:01:29 euler-linux kernel: [ 5913.077446]  [<ffffffff8104f0e0>=
] ? __thread_do_softirq+0x210/0x210
Apr 20 11:01:29 euler-linux kernel: [ 5913.077449]  [<ffffffff8104f0e0>=
] ? __thread_do_softirq+0x210/0x210
Apr 20 11:01:29 euler-linux kernel: [ 5913.077451]  [<ffffffff8106c7de>=
] kthread+0xae/0xc0
Apr 20 11:01:29 euler-linux kernel: [ 5913.077455]  [<ffffffff814fff74>=
] kernel_thread_helper+0x4/0x10
Apr 20 11:01:29 euler-linux kernel: [ 5913.077459]  [<ffffffff8107ad86>=
] ? finish_task_switch+0x86/0x120
Apr 20 11:01:29 euler-linux kernel: [ 5913.077462]  [<ffffffff814f7774>=
] ? retint_restore_args+0x13/0x13
Apr 20 11:01:29 euler-linux kernel: [ 5913.077465]  [<ffffffff8106c730>=
] ? kthreadd+0x310/0x310
Apr 20 11:01:29 euler-linux kernel: [ 5913.077468]  [<ffffffff814fff70>=
] ? gs_change+0x13/0x13
Apr 20 11:01:29 euler-linux kernel: [ 7880.565457] Adding 12284k swap o=
n /home/swap.  Priority:-2 extents:5 across:12588k=20
Apr 20 11:01:29 euler-linux kernel: [ 7880.832285] Adding 12284k swap o=
n /home/swap.  Priority:-2 extents:5 across:12364k=20
Apr 20 11:01:29 euler-linux kernel: [ 7881.278362] process `sysctl' is =
using deprecated sysctl (syscall) net.ipv6.neigh.default.base_reachable=
_time; Use net.ipv6.neigh.default.base_reachable_time_ms instead.
