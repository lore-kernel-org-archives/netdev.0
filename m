From: Dmitry Vyukov <dvyukov@google.com>
Subject: net/rds: use-after-free in inet_create
Date: Tue, 28 Feb 2017 15:22:36 +0100
Message-ID: <CACT4Y+bi=rZr9yrajA0o0iUeR4N0q-sXYudBVsOeOiHbuApBeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: santosh.shilimkar@oracle.com, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've got the following report while running syzkaller fuzzer on
linux-next/8d01c069486aca75b8f6018a759215b0ed0c91f0. So far it
happened only once. net was somehow deleted from underneath
inet_create. I've noticed that rds uses sock_create_kern which does
not take net reference. What is that that must keep net alive then?

==================================================================
BUG: KASAN: use-after-free in inet_create+0xdf5/0xf60
net/ipv4/af_inet.c:337 at addr ffff880150898704
Read of size 4 by task kworker/u4:6/3522
CPU: 0 PID: 3522 Comm: kworker/u4:6 Not tainted 4.10.0-next-20170228+ #2
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
Workqueue: krdsd rds_connect_worker
Call Trace:
 __asan_report_load4_noabort+0x29/0x30 mm/kasan/report.c:331
 inet_create+0xdf5/0xf60 net/ipv4/af_inet.c:337
 __sock_create+0x4e4/0x870 net/socket.c:1197
 sock_create_kern+0x3f/0x50 net/socket.c:1243
 rds_tcp_conn_path_connect+0x29b/0x9d0 net/rds/tcp_connect.c:108
 rds_connect_worker+0x158/0x1e0 net/rds/threads.c:164
 process_one_work+0xbd0/0x1c10 kernel/workqueue.c:2096
 worker_thread+0x223/0x1990 kernel/workqueue.c:2230
 kthread+0x326/0x3f0 kernel/kthread.c:227
 ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
Object at ffff880150898200, in cache net_namespace size: 6784
Allocated:
PID = 3243
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:546
 kmem_cache_alloc+0x102/0x680 mm/slab.c:3568
 kmem_cache_zalloc include/linux/slab.h:653 [inline]
 net_alloc net/core/net_namespace.c:339 [inline]
 copy_net_ns+0x196/0x530 net/core/net_namespace.c:379
 create_new_namespaces+0x409/0x860 kernel/nsproxy.c:106
 copy_namespaces+0x34d/0x420 kernel/nsproxy.c:164
 copy_process.part.42+0x223b/0x4d50 kernel/fork.c:1675
 copy_process kernel/fork.c:1497 [inline]
 _do_fork+0x200/0xff0 kernel/fork.c:1960
 SYSC_clone kernel/fork.c:2070 [inline]
 SyS_clone+0x37/0x50 kernel/fork.c:2064
 do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:280
 return_from_SYSCALL_64+0x0/0x7a
Freed:
PID = 3544
 __cache_free mm/slab.c:3510 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3770
 net_free+0xd7/0x110 net/core/net_namespace.c:355
 net_drop_ns+0x31/0x40 net/core/net_namespace.c:362
 cleanup_net+0x7f4/0xa90 net/core/net_namespace.c:479
 process_one_work+0xbd0/0x1c10 kernel/workqueue.c:2096
 worker_thread+0x223/0x1990 kernel/workqueue.c:2230
 kthread+0x326/0x3f0 kernel/kthread.c:227
 ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
Memory state around the buggy address:
 ffff880150898600: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880150898680: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff880150898700: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                   ^
 ffff880150898780: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880150898800: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================
