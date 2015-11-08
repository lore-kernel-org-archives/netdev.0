From: Dmitry Vyukov <dvyukov@google.com>
Subject: deadlock between setsockopt/getsockopt
Date: Sun, 8 Nov 2015 11:15:30 +0100
Message-ID: <CACT4Y+YvHCfKQsHi+wfCGyaZcOb1TG6vq2U+Fh08pfEt7b9Dvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35876 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbbKHKPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 05:15:51 -0500
Received: by wmww144 with SMTP id w144so56193875wmw.1
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2015 02:15:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I've got the following deadlock report on commit
d1e41ff11941784f469f17795a4d9425c2eb4b7a (Nov 5).


[ INFO: possible circular locking dependency detected ]
4.3.0+ #39 Not tainted
-------------------------------------------------------
syzkaller_execu/18311 is trying to acquire lock:
 (rtnl_mutex){+.+.+.}, at: [<ffffffff827f9917>] rtnl_lock+0x17/0x20
net/core/rtnetlink.c:70

but task is already holding lock:
 (sk_lock-AF_INET){+.+.+.}, at: [<     inline     >] lock_sock
include/net/sock.h:1477
 (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff8290b171>]
do_ip_getsockopt.part.9+0x111/0x1510 net/ipv4/ip_sockglue.c:1272

which lock already depends on the new lock.

the existing dependency chain (in reverse order) is:

-> #1 (sk_lock-AF_INET){+.+.+.}:
       [<ffffffff811f655d>] lock_acquire+0x16d/0x2f0
kernel/locking/lockdep.c:3585
       [<ffffffff8276bbc8>] lock_sock_nested+0xb8/0x110 net/core/sock.c:2443
       [<     inline     >] lock_sock include/net/sock.h:1477
       [<ffffffff8290d623>] do_ip_setsockopt.isra.12+0x193/0x2af0
net/ipv4/ip_sockglue.c:621
       [<ffffffff8290ffba>] ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1202
       [<ffffffff8292e712>] tcp_setsockopt+0x82/0xd0 net/ipv4/tcp.c:2616
       [<ffffffff827697f5>] sock_common_setsockopt+0x95/0xd0
net/core/sock.c:2643
       [<     inline     >] SYSC_setsockopt net/socket.c:1757
       [<ffffffff82766728>] SyS_setsockopt+0x158/0x240 net/socket.c:1736
       [<ffffffff82f21951>] entry_SYSCALL_64_fastpath+0x31/0x9a
arch/x86/entry/entry_64.S:187

-> #0 (rtnl_mutex){+.+.+.}:
       [<     inline     >] check_prev_add kernel/locking/lockdep.c:1853
       [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1958
       [<     inline     >] validate_chain kernel/locking/lockdep.c:2144
       [<ffffffff811f3769>] __lock_acquire+0x36d9/0x40e0
kernel/locking/lockdep.c:3206
       [<ffffffff811f655d>] lock_acquire+0x16d/0x2f0
kernel/locking/lockdep.c:3585
       [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:518
       [<ffffffff82f18dcc>] mutex_lock_nested+0x9c/0x8f0
kernel/locking/mutex.c:618
       [<ffffffff827f9917>] rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70
       [<ffffffff82a033a0>] ip_mc_msfget+0xe0/0x620 net/ipv4/igmp.c:2398
       [<ffffffff8290b465>] do_ip_getsockopt.part.9+0x405/0x1510
net/ipv4/ip_sockglue.c:1399
       [<     inline     >] do_ip_getsockopt net/ipv4/ip_sockglue.c:1264
       [<ffffffff8290c808>] ip_getsockopt+0xa8/0x1c0 net/ipv4/ip_sockglue.c:1495
       [<ffffffff8292b8f2>] tcp_getsockopt+0x82/0xd0 net/ipv4/tcp.c:2916
       [<ffffffff82769415>] sock_common_getsockopt+0x95/0xd0
net/core/sock.c:2602
       [<     inline     >] SYSC_getsockopt net/socket.c:1788
       [<ffffffff82766952>] SyS_getsockopt+0x142/0x230 net/socket.c:1770

other info that might help us debug this:

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(sk_lock-AF_INET);
                               lock(rtnl_mutex);
                               lock(sk_lock-AF_INET);
  lock(rtnl_mutex);

 *** DEADLOCK ***

1 lock held by syzkaller_execu/18311:
 #0:  (sk_lock-AF_INET){+.+.+.}, at: [<     inline     >] lock_sock
include/net/sock.h:1477
 #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff8290b171>]
do_ip_getsockopt.part.9+0x111/0x1510 net/ipv4/ip_sockglue.c:1272

stack backtrace:
CPU: 1 PID: 18311 Comm: syzkaller_execu Not tainted 4.3.0+ #39
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff88005b647598 ffffffff81aad406 ffffffff845cb400
 ffffffff84612200 ffffffff845cb400 ffff88005b6475e0 ffffffff811ec511
 ffff88005b6476e0 000000006c7d5800 ffff88006c7d5fb0 ffff88006c7d5fd2
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81aad406>] dump_stack+0x68/0x92 lib/dump_stack.c:50
 [<ffffffff811ec511>] print_circular_bug+0x2d1/0x390
kernel/locking/lockdep.c:1226
 [<     inline     >] check_prev_add kernel/locking/lockdep.c:1853
 [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1958
 [<     inline     >] validate_chain kernel/locking/lockdep.c:2144
 [<ffffffff811f3769>] __lock_acquire+0x36d9/0x40e0 kernel/locking/lockdep.c:3206
 [<ffffffff811f655d>] lock_acquire+0x16d/0x2f0 kernel/locking/lockdep.c:3585
 [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:518
 [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:518
 [<ffffffff82f18dcc>] mutex_lock_nested+0x9c/0x8f0 kernel/locking/mutex.c:618
 [<ffffffff827f9917>] rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70
 [<ffffffff82a033a0>] ip_mc_msfget+0xe0/0x620 net/ipv4/igmp.c:2398
 [<ffffffff8290b465>] do_ip_getsockopt.part.9+0x405/0x1510
net/ipv4/ip_sockglue.c:1399
 [<     inline     >] do_ip_getsockopt net/ipv4/ip_sockglue.c:1264
 [<ffffffff8290c808>] ip_getsockopt+0xa8/0x1c0 net/ipv4/ip_sockglue.c:1495
 [<ffffffff8292b8f2>] tcp_getsockopt+0x82/0xd0 net/ipv4/tcp.c:2916
 [<ffffffff82769415>] sock_common_getsockopt+0x95/0xd0 net/core/sock.c:2602
 [<     inline     >] SYSC_getsockopt net/socket.c:1788
 [<ffffffff82766952>] SyS_getsockopt+0x142/0x230 net/socket.c:1770


Found with syzkaller system call fuzzer (https://github.com/google/syzkaller).
