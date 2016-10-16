From: Baozeng Ding <sploving1@gmail.com>
Subject: net/ipv6: potential deadlock in do_ipv6_setsockopt
Date: Sun, 16 Oct 2016 21:34:58 +0800
Message-ID: <f43836e6-82b2-4673-1f5e-cd41ba0bc609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34206 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753318AbcJPNff (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2016 09:35:35 -0400
Received: by mail-oi0-f68.google.com with SMTP id p136so10599552oic.1
        for <netdev@vger.kernel.org>; Sun, 16 Oct 2016 06:35:13 -0700 (PDT)
Received: from [192.168.1.101] ([119.80.189.206])
        by smtp.gmail.com with ESMTPSA id e100sm1696065ote.35.2016.10.16.06.35.04
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Oct 2016 06:35:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
While running syzkaller fuzzer I have got the following deadlock
report. The kernel version is 4.8.0+ (on Oct 7 commit d1f5323370fceaed43a7ee38f4c7bfc7e70f28d0). Unfortunately I failed to find a reproducer for it. 
===============================================================================
[ INFO: possible circular locking dependency detected ]
4.8.0+ #39 Not tainted
-------------------------------------------------------
syz-executor/21301 is trying to acquire lock:
 ([  165.136033] rtnl_mutex
[<ffffffff84ce81d7>] rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70

but task is already holding lock:
 ([  165.136033] sk_lock-AF_INET6
[<ffffffff85245db1>] do_ipv6_setsockopt.isra.7+0x1f1/0x2960

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

:
       [  165.136033] [<ffffffff81427398>] lock_acquire+0x1a8/0x380 kernel/locking/lockdep.c:3746
       [  165.136033] [<ffffffff84c54c0b>] lock_sock_nested+0xcb/0x120 net/core/sock.c:2493
       [  165.136033] [<ffffffff85245e28>] do_ipv6_setsockopt.isra.7+0x268/0x2960
       [  165.136033] [<ffffffff852485bb>] ipv6_setsockopt+0x9b/0x140
       [  165.136033] [<ffffffff8525a6c5>] udpv6_setsockopt+0x45/0x80 net/ipv6/udp.c:1344
       [  165.136033] [<ffffffff84c4ed85>] sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2688
       [  165.136033] [<     inline     >] SYSC_setsockopt net/socket.c:1742
       [  165.136033] [<ffffffff84c4bff8>] SyS_setsockopt+0x158/0x240 net/socket.c:1721
       [  165.136033] [<ffffffff85e4d685>] entry_SYSCALL_64_fastpath+0x23/0xc6

:
       [  165.136033] [<     inline     >] check_prev_add kernel/locking/lockdep.c:1829
       [  165.136033] [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1939
       [  165.136033] [<     inline     >] validate_chain kernel/locking/lockdep.c:2266
       [  165.136033] [<ffffffff81424d19>] __lock_acquire+0x35a9/0x4bc0 kernel/locking/lockdep.c:3335
       [  165.136033] [<ffffffff81427398>] lock_acquire+0x1a8/0x380 kernel/locking/lockdep.c:3746
       [  165.136033] [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:521
       [  165.136033] [<ffffffff85e44721>] mutex_lock_nested+0xb1/0x860 kernel/locking/mutex.c:621
       [  165.136033] [<ffffffff84ce81d7>] rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70
       [  165.136033] [<ffffffff8528116e>] ipv6_sock_mc_close+0xfe/0x350 net/ipv6/mcast.c:288
       [  165.136033] [<ffffffff85247ebc>] do_ipv6_setsockopt.isra.7+0x22fc/0x2960
       [  165.136033] [<ffffffff852485bb>] ipv6_setsockopt+0x9b/0x140
       [  165.136033] [<ffffffff8525a6c5>] udpv6_setsockopt+0x45/0x80 net/ipv6/udp.c:1344
       [  165.136033] [<ffffffff84c4ed85>] sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2688
       [  165.136033] [<     inline     >] SYSC_setsockopt net/socket.c:1742
       [  165.136033] [<ffffffff84c4bff8>] SyS_setsockopt+0x158/0x240 net/socket.c:1721
       [  165.136033] [<ffffffff85e4d685>] entry_SYSCALL_64_fastpath+0x23/0xc6
other info that might help us debug this:

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock([  165.136033] sk_lock-AF_INET6
);
                               lock([  165.136033] rtnl_mutex
);
                               lock([  165.136033] sk_lock-AF_INET6
);
  lock([  165.136033] rtnl_mutex
);

 *** DEADLOCK ***

1 lock held by syz-executor/21301:
 #0: [  165.136033]  (

stack backtrace:
CPU: 1 PID: 21301 Comm: syz-executor Not tainted 4.8.0+ #39
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
 ffff880017217580 ffffffff829f835b ffffffff88d65790 ffffffff88d65790
 ffffffff88dc6b70 ffff880016f41fd8 ffff8800172175d0 ffffffff8141df18
 ffff880016f41ffa dffffc0000000000 000000008764c180 ffff880016f41fd8
Call Trace:
 [<ffffffff829f835b>] dump_stack+0xb3/0x118 lib/dump_stack.c:15
 [<ffffffff8141df18>] print_circular_bug+0x288/0x340 kernel/locking/lockdep.c:1202
 [<     inline     >] check_prev_add kernel/locking/lockdep.c:1829
 [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1939
 [<     inline     >] validate_chain kernel/locking/lockdep.c:2266
 [<ffffffff81424d19>] __lock_acquire+0x35a9/0x4bc0 kernel/locking/lockdep.c:3335
 [<ffffffff81427398>] lock_acquire+0x1a8/0x380 kernel/locking/lockdep.c:3746
 [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:521
 [<ffffffff85e44721>] mutex_lock_nested+0xb1/0x860 kernel/locking/mutex.c:621
 [<ffffffff84ce81d7>] rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70
 [<ffffffff8528116e>] ipv6_sock_mc_close+0xfe/0x350 net/ipv6/mcast.c:288
 [<ffffffff85247ebc>] do_ipv6_setsockopt.isra.7+0x22fc/0x2960
 [<ffffffff852485bb>] ipv6_setsockopt+0x9b/0x140
 [<ffffffff8525a6c5>] udpv6_setsockopt+0x45/0x80 net/ipv6/udp.c:1344
 [<ffffffff84c4ed85>] sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2688
 [<     inline     >] SYSC_setsockopt net/socket.c:1742
 [<ffffffff84c4bff8>] SyS_setsockopt+0x158/0x240 net/socket.c:1721
 [<ffffffff85e4d685>] entry_SYSCALL_64_fastpath+0x23/0xc6

Thanks && Best Regards,
Baozeng Ding
