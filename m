From: Dmitry Vyukov <dvyukov@google.com>
Subject: sctp: suspicious rcu_dereference_check() usage in sctp_epaddr_lookup_transport
Date: Tue, 13 Dec 2016 19:07:01 +0100
Message-ID: <CACT4Y+bEi6aXTTrk4P37hFnMdyte0voxUVdz8t0XQP95PgH9+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: Vladislav Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am getting the following reports while running syzkaller fuzzer:

[ INFO: suspicious RCU usage. ]
4.9.0+ #85 Not tainted
-------------------------------
./include/linux/rhashtable.h:572 suspicious rcu_dereference_check() usage!

other info that might help us debug this:

rcu_scheduler_active = 1, debug_locks = 0
1 lock held by syz-executor1/18023:
 #0:  (sk_lock-AF_INET){+.+.+.}, at: [<     inline     >] lock_sock
include/net/sock.h:1454
 #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff87bb3ccf>]
sctp_getsockopt+0x45f/0x6800 net/sctp/socket.c:6432

stack backtrace:
CPU: 2 PID: 18023 Comm: syz-executor1 Not tainted 4.9.0+ #85
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
[<     inline     >] __dump_stack lib/dump_stack.c:15
[<        none        >] dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
[<        none        >] lockdep_rcu_suspicious+0x139/0x180
kernel/locking/lockdep.c:4448
[<     inline     >] __rhashtable_lookup ./include/linux/rhashtable.h:572
[<     inline     >] rhltable_lookup ./include/linux/rhashtable.h:660
[<        none        >] sctp_epaddr_lookup_transport+0x641/0x930
net/sctp/input.c:946
[<        none        >] sctp_endpoint_lookup_assoc+0x83/0x120
net/sctp/endpointola.c:335
[<        none        >] sctp_addr_id2transport+0xaf/0x1e0 net/sctp/socket.c:241
[<        none        >] sctp_getsockopt_peer_addr_info+0x216/0x630
net/sctp/socket.c:4625
[<        none        >] sctp_getsockopt+0x2860/0x6800 net/sctp/socket.c:6500
[<        none        >] sock_common_getsockopt+0x9a/0xe0 net/core/sock.c:2685
[<     inline     >] SYSC_getsockopt net/socket.c:1819
[<        none        >] SyS_getsockopt+0x245/0x380 net/socket.c:1801
[<        none        >] entry_SYSCALL_64_fastpath+0x23/0xc6
arch/x86/entry/entry_64.S:203

On commit e7aa8c2eb11ba69b1b69099c3c7bd6be3087b0ba (Dec 12).
