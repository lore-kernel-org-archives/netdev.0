From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/ipv4: deadlock in ip_ra_control
Date: Thu, 2 Mar 2017 10:40:23 +0100
Message-ID: <CACT4Y+aWYLbu5Eq1WN_T6q_zDBUdP8wiAVJK1x1D_XspQSY-RQ@mail.gmail.com>
References: <CACT4Y+b-c=_QC51h0Qgp4buG=6cWO1xax7MrKgFS1BKV2=mdQg@mail.gmail.com>
 <CAM_iQpX=Vb-0xMjwOrriYcG38GT+U9zknggVbCb0_pBUh1NMkQ@mail.gmail.com>
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
In-Reply-To: <CAM_iQpX=Vb-0xMjwOrriYcG38GT+U9zknggVbCb0_pBUh1NMkQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 1, 2017 at 6:18 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, Mar 1, 2017 at 2:44 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> Hello,
>>
>> I've got the following deadlock report while running syzkaller fuzzer
>> on linux-next/51788aebe7cae79cb334ad50641347465fc188fd:
>>
>> ======================================================
>> [ INFO: possible circular locking dependency detected ]
>> 4.10.0-next-20170301+ #1 Not tainted
>> -------------------------------------------------------
>> syz-executor1/3394 is trying to acquire lock:
>>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff838864cc>] lock_sock
>> include/net/sock.h:1460 [inline]
>>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff838864cc>]
>> do_ip_setsockopt.isra.12+0x21c/0x3540 net/ipv4/ip_sockglue.c:652
>>
>> but task is already holding lock:
>>  (rtnl_mutex){+.+.+.}, at: [<ffffffff836fbd97>] rtnl_lock+0x17/0x20
>> net/core/rtnetlink.c:70
>>
>> which lock already depends on the new lock.
>>
>>
>> the existing dependency chain (in reverse order) is:
>>
>> -> #1 (rtnl_mutex){+.+.+.}:
>>        validate_chain kernel/locking/lockdep.c:2265 [inline]
>>        __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
>>        lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
>>        __mutex_lock_common kernel/locking/mutex.c:754 [inline]
>>        __mutex_lock+0x172/0x1730 kernel/locking/mutex.c:891
>>        mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:906
>>        rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70
>>        mrtsock_destruct+0x86/0x2c0 net/ipv4/ipmr.c:1281
>>        ip_ra_control+0x459/0x600 net/ipv4/ip_sockglue.c:372
>>        do_ip_setsockopt.isra.12+0x1064/0x3540 net/ipv4/ip_sockglue.c:1161
>>        ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1264
>>        raw_setsockopt+0xb7/0xd0 net/ipv4/raw.c:839
>>        sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2725
>>        SYSC_setsockopt net/socket.c:1786 [inline]
>>        SyS_setsockopt+0x25c/0x390 net/socket.c:1765
>>        entry_SYSCALL_64_fastpath+0x1f/0xc2
>>
>> -> #0 (sk_lock-AF_INET){+.+.+.}:
>>        check_prev_add kernel/locking/lockdep.c:1828 [inline]
>>        check_prevs_add+0xa8f/0x19f0 kernel/locking/lockdep.c:1938
>>        validate_chain kernel/locking/lockdep.c:2265 [inline]
>>        __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
>>        lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
>>        lock_sock_nested+0xcb/0x120 net/core/sock.c:2530
>>        lock_sock include/net/sock.h:1460 [inline]
>>        do_ip_setsockopt.isra.12+0x21c/0x3540 net/ipv4/ip_sockglue.c:652
>>        ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1264
>>        tcp_setsockopt+0x82/0xd0 net/ipv4/tcp.c:2721
>>        sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2725
>>        SYSC_setsockopt net/socket.c:1786 [inline]
>>        SyS_setsockopt+0x25c/0x390 net/socket.c:1765
>>        entry_SYSCALL_64_fastpath+0x1f/0xc2
>>
>
> Please try the attached patch (compile only).


Pushed the patch to the bots.
Thanks
