From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: deadlock on genl_mutex
Date: Sun, 29 Jan 2017 11:11:15 +0100
Message-ID: <CACT4Y+bUNeDM5SeZa0cQSuSJ0rq3i0Y063wK9cUvG9oxuQP7YQ@mail.gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f182.google.com ([209.85.217.182]:34507 "EHLO
        mail-ua0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750748AbdA2Kps (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 05:45:48 -0500
Received: by mail-ua0-f182.google.com with SMTP id 35so233386748uak.1
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 02:45:05 -0800 (PST)
In-Reply-To: <CAM_iQpW2x5xeBpxnZx+k+vnKkjxWPycCBpiKZE41Kcp5gBsN4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 9, 2016 at 6:08 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
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


Cong, any success with breaking the chain?

Still happenning on f0ad17712b9f71c24e2b8b9725230ef57232377f. Or is it
a different one?


[ INFO: possible circular locking dependency detected ]
4.10.0-rc3+ #4 Not tainted
-------------------------------------------------------
syz-executor9/2705 is trying to acquire lock:
 (genl_mutex){+.+.+.}, at: [<ffffffff836f58fe>] genl_lock
net/netlink/genetlink.c:32 [inline]
 (genl_mutex){+.+.+.}, at: [<ffffffff836f58fe>]
genl_family_rcv_msg+0xdae/0x1040 net/netlink/genetlink.c:547

but task is already holding lock:
 (rtnl_mutex){+.+.+.}, at: [<ffffffff836416e7>] rtnl_lock+0x17/0x20
net/core/rtnetlink.c:70

which lock already depends on the new lock.

the existing dependency chain (in reverse order) is:

-> #1 (rtnl_mutex){+.+.+.}:

[<ffffffff8157e729>] validate_chain kernel/locking/lockdep.c:2265 [inline]
[<ffffffff8157e729>] __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
[<ffffffff815808b1>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
[<ffffffff843f9de0>] __mutex_lock_common kernel/locking/mutex.c:639 [inline]
[<ffffffff843f9de0>] mutex_lock_nested+0x290/0x1730 kernel/locking/mutex.c:753
[<ffffffff836416e7>] rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70
[<ffffffff83fd5e9e>] nl80211_pre_doit+0x2fe/0x570 net/wireless/nl80211.c:11847
[<ffffffff836f52b0>] genl_family_rcv_msg+0x760/0x1040
net/netlink/genetlink.c:591
[<ffffffff836f807a>] genl_rcv_msg+0x19a/0x330 net/netlink/genetlink.c:620
[<ffffffff836f36cb>] netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
[<ffffffff836f4b38>] genl_rcv+0x28/0x40 net/netlink/genetlink.c:631
[<ffffffff836f1f14>] netlink_unicast_kernel
net/netlink/af_netlink.c:1231 [inline]
[<ffffffff836f1f14>] netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1257
[<ffffffff836f2bcf>] netlink_sendmsg+0xa9f/0xe50 net/netlink/af_netlink.c:1803
[<ffffffff83572d3a>] sock_sendmsg_nosec net/socket.c:635 [inline]
[<ffffffff83572d3a>] sock_sendmsg+0xca/0x110 net/socket.c:645
[<ffffffff8357557a>] ___sys_sendmsg+0x8fa/0x9f0 net/socket.c:1985
[<ffffffff83578138>] __sys_sendmsg+0x138/0x300 net/socket.c:2019
[<ffffffff8357832d>] SYSC_sendmsg net/socket.c:2030 [inline]
[<ffffffff8357832d>] SyS_sendmsg+0x2d/0x50 net/socket.c:2026
[<ffffffff8440e7c1>] entry_SYSCALL_64_fastpath+0x1f/0xc2

-> #0 (genl_mutex){+.+.+.}:

[<ffffffff8157847f>] check_prev_add kernel/locking/lockdep.c:1828 [inline]
[<ffffffff8157847f>] check_prevs_add+0xa8f/0x19f0 kernel/locking/lockdep.c:1938
[<ffffffff8157e729>] validate_chain kernel/locking/lockdep.c:2265 [inline]
[<ffffffff8157e729>] __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
[<ffffffff815808b1>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
[<ffffffff843f9de0>] __mutex_lock_common kernel/locking/mutex.c:639 [inline]
[<ffffffff843f9de0>] mutex_lock_nested+0x290/0x1730 kernel/locking/mutex.c:753
[<ffffffff836f58fe>] genl_lock net/netlink/genetlink.c:32 [inline]
[<ffffffff836f58fe>] genl_family_rcv_msg+0xdae/0x1040
net/netlink/genetlink.c:547
[<ffffffff836f807a>] genl_rcv_msg+0x19a/0x330 net/netlink/genetlink.c:620
[<ffffffff836f36cb>] netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
[<ffffffff836f4b38>] genl_rcv+0x28/0x40 net/netlink/genetlink.c:631
[<ffffffff836f1f14>] netlink_unicast_kernel
net/netlink/af_netlink.c:1231 [inline]
[<ffffffff836f1f14>] netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1257
[<ffffffff836f2bcf>] netlink_sendmsg+0xa9f/0xe50 net/netlink/af_netlink.c:1803
[<ffffffff83572d3a>] sock_sendmsg_nosec net/socket.c:635 [inline]
[<ffffffff83572d3a>] sock_sendmsg+0xca/0x110 net/socket.c:645
[<ffffffff835730a6>] sock_write_iter+0x326/0x600 net/socket.c:848
[<ffffffff81a3c493>] new_sync_write fs/read_write.c:499 [inline]
[<ffffffff81a3c493>] __vfs_write+0x483/0x740 fs/read_write.c:512
[<ffffffff81a42227>] vfs_write+0x187/0x530 fs/read_write.c:560
[<ffffffff81a4675b>] SYSC_write fs/read_write.c:607 [inline]
[<ffffffff81a4675b>] SyS_write+0xfb/0x230 fs/read_write.c:599
[<ffffffff8440e7c1>] entry_SYSCALL_64_fastpath+0x1f/0xc2

other info that might help us debug this:

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(rtnl_mutex);
                               lock(genl_mutex);
                               lock(rtnl_mutex);
  lock(genl_mutex);

 *** DEADLOCK ***

2 locks held by syz-executor9/2705:
 #0:  (cb_lock){++++++}, at: [<ffffffff836f4b29>] genl_rcv+0x19/0x40
net/netlink/genetlink.c:630
 #1:  (rtnl_mutex){+.+.+.}, at: [<ffffffff836416e7>]
rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70

stack backtrace:
CPU: 1 PID: 2705 Comm: syz-executor9 Not tainted 4.10.0-rc3+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 print_circular_bug+0x307/0x3b0 kernel/locking/lockdep.c:1202
 check_prev_add kernel/locking/lockdep.c:1828 [inline]
 check_prevs_add+0xa8f/0x19f0 kernel/locking/lockdep.c:1938
 validate_chain kernel/locking/lockdep.c:2265 [inline]
 __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
 lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
 __mutex_lock_common kernel/locking/mutex.c:639 [inline]
 mutex_lock_nested+0x290/0x1730 kernel/locking/mutex.c:753
 genl_lock net/netlink/genetlink.c:32 [inline]
 genl_family_rcv_msg+0xdae/0x1040 net/netlink/genetlink.c:547
 genl_rcv_msg+0x19a/0x330 net/netlink/genetlink.c:620
 netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
 genl_rcv+0x28/0x40 net/netlink/genetlink.c:631
 netlink_unicast_kernel net/netlink/af_netlink.c:1231 [inline]
 netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1257
 netlink_sendmsg+0xa9f/0xe50 net/netlink/af_netlink.c:1803
 sock_sendmsg_nosec net/socket.c:635 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:645
 sock_write_iter+0x326/0x600 net/socket.c:848
 new_sync_write fs/read_write.c:499 [inline]
 __vfs_write+0x483/0x740 fs/read_write.c:512
 vfs_write+0x187/0x530 fs/read_write.c:560
 SYSC_write fs/read_write.c:607 [inline]
 SyS_write+0xfb/0x230 fs/read_write.c:599
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x44f5e9
RSP: 002b:00007fdba138cb58 EFLAGS: 00000212 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000020000fdc RCX: 000000000044f5e9
RDX: 0000000000000024 RSI: 0000000020000fdc RDI: 0000000000000006
RBP: 0000000000000006 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000212 R12: 0000000000700000
R13: 0000000000000002 R14: 0000000000000010 R15: 0000000000000000
