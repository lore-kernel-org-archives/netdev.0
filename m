From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/ipv4: deadlock in ip_ra_control
Date: Fri, 3 Mar 2017 19:45:48 +0100
Message-ID: <CACT4Y+Z7NyGuOQUDxaeAVJLJFP6wWAKxtv718uGu42U6rQ32Mw@mail.gmail.com>
References: <CACT4Y+b-c=_QC51h0Qgp4buG=6cWO1xax7MrKgFS1BKV2=mdQg@mail.gmail.com>
 <CAM_iQpX=Vb-0xMjwOrriYcG38GT+U9zknggVbCb0_pBUh1NMkQ@mail.gmail.com>
 <CACT4Y+aWYLbu5Eq1WN_T6q_zDBUdP8wiAVJK1x1D_XspQSY-RQ@mail.gmail.com> <CACT4Y+b0uuE+YarvhfvWOanaoKxTsv92C5LC8btLOwEAG9Lr1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+b0uuE+YarvhfvWOanaoKxTsv92C5LC8btLOwEAG9Lr1w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 7:43 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Thu, Mar 2, 2017 at 10:40 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Wed, Mar 1, 2017 at 6:18 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Wed, Mar 1, 2017 at 2:44 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>> Hello,
>>>>
>>>> I've got the following deadlock report while running syzkaller fuzzer
>>>> on linux-next/51788aebe7cae79cb334ad50641347465fc188fd:
>>>>
>>>> ======================================================
>>>> [ INFO: possible circular locking dependency detected ]
>>>> 4.10.0-next-20170301+ #1 Not tainted
>>>> -------------------------------------------------------
>>>> syz-executor1/3394 is trying to acquire lock:
>>>>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff838864cc>] lock_sock
>>>> include/net/sock.h:1460 [inline]
>>>>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff838864cc>]
>>>> do_ip_setsockopt.isra.12+0x21c/0x3540 net/ipv4/ip_sockglue.c:652
>>>>
>>>> but task is already holding lock:
>>>>  (rtnl_mutex){+.+.+.}, at: [<ffffffff836fbd97>] rtnl_lock+0x17/0x20
>>>> net/core/rtnetlink.c:70
>>>>
>>>> which lock already depends on the new lock.
>>>>
>>>>
>>>> the existing dependency chain (in reverse order) is:
>>>>
>>>> -> #1 (rtnl_mutex){+.+.+.}:
>>>>        validate_chain kernel/locking/lockdep.c:2265 [inline]
>>>>        __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
>>>>        lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
>>>>        __mutex_lock_common kernel/locking/mutex.c:754 [inline]
>>>>        __mutex_lock+0x172/0x1730 kernel/locking/mutex.c:891
>>>>        mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:906
>>>>        rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70
>>>>        mrtsock_destruct+0x86/0x2c0 net/ipv4/ipmr.c:1281
>>>>        ip_ra_control+0x459/0x600 net/ipv4/ip_sockglue.c:372
>>>>        do_ip_setsockopt.isra.12+0x1064/0x3540 net/ipv4/ip_sockglue.c:1161
>>>>        ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1264
>>>>        raw_setsockopt+0xb7/0xd0 net/ipv4/raw.c:839
>>>>        sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2725
>>>>        SYSC_setsockopt net/socket.c:1786 [inline]
>>>>        SyS_setsockopt+0x25c/0x390 net/socket.c:1765
>>>>        entry_SYSCALL_64_fastpath+0x1f/0xc2
>>>>
>>>> -> #0 (sk_lock-AF_INET){+.+.+.}:
>>>>        check_prev_add kernel/locking/lockdep.c:1828 [inline]
>>>>        check_prevs_add+0xa8f/0x19f0 kernel/locking/lockdep.c:1938
>>>>        validate_chain kernel/locking/lockdep.c:2265 [inline]
>>>>        __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
>>>>        lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
>>>>        lock_sock_nested+0xcb/0x120 net/core/sock.c:2530
>>>>        lock_sock include/net/sock.h:1460 [inline]
>>>>        do_ip_setsockopt.isra.12+0x21c/0x3540 net/ipv4/ip_sockglue.c:652
>>>>        ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1264
>>>>        tcp_setsockopt+0x82/0xd0 net/ipv4/tcp.c:2721
>>>>        sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2725
>>>>        SYSC_setsockopt net/socket.c:1786 [inline]
>>>>        SyS_setsockopt+0x25c/0x390 net/socket.c:1765
>>>>        entry_SYSCALL_64_fastpath+0x1f/0xc2
>>>>
>>>
>>> Please try the attached patch (compile only).
>>
>>
>> Pushed the patch to the bots.
>> Thanks
>
>
> This patch triggers:
>
> [   57.748990] RTNL: assertion failed at net/ipv4/ipmr.c (1236)
> [   57.749022] CPU: 1 PID: 5301 Comm: syz-executor2 Not tainted 4.10.0+ #15
> [   57.749026] Hardware name: Google Google Compute Engine/Google
> Compute Engine, BIOS Google 01/01/2011
> [   57.749028] Call Trace:
> [   57.749042]  dump_stack+0x2ee/0x3ef
> [   57.749219]  mrtsock_destruct+0x27e/0x2f0
> [   57.749241]  ip_ra_control+0x459/0x600
> [   57.749287]  raw_close+0x19/0x30
> [   57.749295]  inet_release+0xed/0x1c0
> [   57.749303]  sock_release+0x8d/0x1e0
> [   57.749316]  sock_close+0x16/0x20
> [   57.749323]  __fput+0x332/0x7f0
> [   57.749340]  ____fput+0x15/0x20
> [   57.749347]  task_work_run+0x18a/0x260
> [   57.749372]  do_exit+0x18ef/0x28b0
> [   57.749641]  do_group_exit+0x149/0x420
> [   57.749656]  get_signal+0x7e0/0x1820
> [   57.749697]  do_signal+0xd2/0x2190
> [   57.749746]  exit_to_usermode_loop+0x200/0x2a0
> [   57.749758]  syscall_return_slowpath+0x4d3/0x570
> [   57.749835]  entry_SYSCALL_64_fastpath+0xc0/0xc2
> [   57.749840] RIP: 0033:0x44fb79
> [   57.749843] RSP: 002b:00007fbba84d9cf8 EFLAGS: 00000246 ORIG_RAX:
> 00000000000000ca
> [   57.749850] RAX: fffffffffffffe00 RBX: 0000000000708218 RCX: 000000000044fb79
> [   57.749854] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000708218
> [   57.749857] RBP: 00000000007081f8 R08: 0000000000000000 R09: 0000000000000000
> [   57.749860] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
> [   57.749864] R13: 0000000000a5fc57 R14: 00007fbba84da9c0 R15: 000000000000000c
> [   57.749964]
> [   57.749966] ===============================
> [   57.749967] [ INFO: suspicious RCU usage. ]
> [   57.749971] 4.10.0+ #15 Not tainted
> [   57.749972] -------------------------------
> [   57.749975] net/ipv4/ipmr.c:1238 suspicious
> rcu_dereference_protected() usage!
> [   57.749977]
> [   57.749977] other info that might help us debug this:
> [   57.749977]
> [   57.749980]
> [   57.749980] rcu_scheduler_active = 2, debug_locks = 0
> [   57.749982] no locks held by syz-executor2/5301.
> [   57.749984]
> [   57.749984] stack backtrace:
> [   57.749989] CPU: 1 PID: 5301 Comm: syz-executor2 Not tainted 4.10.0+ #15
> [   57.749993] Hardware name: Google Google Compute Engine/Google
> Compute Engine, BIOS Google 01/01/2011
> [   57.749995] Call Trace:
> [   57.750001]  dump_stack+0x2ee/0x3ef
> [   57.750117]  lockdep_rcu_suspicious+0x139/0x180
> [   57.750122]  mrtsock_destruct+0x167/0x2f0
> [   57.750144]  ip_ra_control+0x459/0x600
> [   57.750182]  raw_close+0x19/0x30
> [   57.750188]  inet_release+0xed/0x1c0
> [   57.750194]  sock_release+0x8d/0x1e0
> [   57.750208]  sock_close+0x16/0x20
> [   57.750213]  __fput+0x332/0x7f0
> [   57.750228]  ____fput+0x15/0x20
> [   57.750233]  task_work_run+0x18a/0x260
> [   57.750256]  do_exit+0x18ef/0x28b0
> [   57.750499]  do_group_exit+0x149/0x420
> [   57.750515]  get_signal+0x7e0/0x1820
> [   57.750556]  do_signal+0xd2/0x2190
> [   57.750604]  exit_to_usermode_loop+0x200/0x2a0
> [   57.750616]  syscall_return_slowpath+0x4d3/0x570
> [   57.750693]  entry_SYSCALL_64_fastpath+0xc0/0xc2
> [   57.750698] RIP: 0033:0x44fb79
> [   57.750701] RSP: 002b:00007fbba84d9cf8 EFLAGS: 00000246 ORIG_RAX:
> 00000000000000ca
> [   57.750708] RAX: fffffffffffffe00 RBX: 0000000000708218 RCX: 000000000044fb79
> [   57.750712] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000708218
> [   57.750716] RBP: 00000000007081f8 R08: 0000000000000000 R09: 0000000000000000
> [   57.750720] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
> [   57.750724] R13: 0000000000a5fc57 R14: 00007fbba84da9c0 R15: 000000000000000c



Humm... but only on mmotm
(git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
auto-latest branch)
linux-next and upstream seem to be fine
