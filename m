From: Dmitry Vyukov <dvyukov@google.com>
Subject: net: use-after-free in recvmmsg
Date: Fri, 22 Jan 2016 21:39:53 +0100
Message-ID: <CACT4Y+YUobBGeFiq5d-==TBB7F2am+wjH6CKVz0uCvw4KuM1dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

While running syzkaller fuzzer I've hit the following use-after-free:

==================================================================
BUG: KASAN: use-after-free in __sys_recvmmsg+0x6fa/0x7f0 at addr
ffff88003b689ce0
Read of size 8 by task syz-executor/11997
=============================================================================
BUG sock_inode_cache (Not tainted): kasan: bad access detected
-----------------------------------------------------------------------------

INFO: Allocated in sock_alloc_inode+0x1d/0x250 age=125 cpu=1 pid=11960
[<      none      >] ___slab_alloc+0x4c2/0x500 mm/slub.c:2470
[<      none      >] __slab_alloc+0x66/0xc0 mm/slub.c:2499
[<     inline     >] slab_alloc_node mm/slub.c:2562
[<     inline     >] slab_alloc mm/slub.c:2604
[<      none      >] kmem_cache_alloc+0x257/0x2d0 mm/slub.c:2609
[<      none      >] sock_alloc_inode+0x1d/0x250 net/socket.c:250
[<      none      >] alloc_inode+0x61/0x180 fs/inode.c:198
[<      none      >] new_inode_pseudo+0x17/0xe0 fs/inode.c:878
[<      none      >] sock_alloc+0x3d/0x260 net/socket.c:541
[<      none      >] __sock_create+0xa7/0x640 net/socket.c:1127
[<     inline     >] sock_create net/socket.c:1203
[<     inline     >] SYSC_socketpair net/socket.c:1275
[<      none      >] SyS_socketpair+0x112/0x4e0 net/socket.c:1254
[<      none      >] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185

INFO: Freed in sock_destroy_inode+0x56/0x70 age=25 cpu=1 pid=11960
[<      none      >] __slab_free+0x1fc/0x320 mm/slub.c:2680
[<     inline     >] slab_free mm/slub.c:2835
[<      none      >] kmem_cache_free+0x2ec/0x370 mm/slub.c:2844
[<      none      >] sock_destroy_inode+0x56/0x70 net/socket.c:280
[<      none      >] destroy_inode+0xc7/0x130 fs/inode.c:255
[<      none      >] evict+0x329/0x500 fs/inode.c:559
[<     inline     >] iput_final fs/inode.c:1477
[<      none      >] iput+0x45f/0x860 fs/inode.c:1504
[<     inline     >] dentry_iput fs/dcache.c:358
[<      none      >] __dentry_kill+0x457/0x620 fs/dcache.c:543
[<     inline     >] dentry_kill fs/dcache.c:587
[<      none      >] dput+0x65b/0x740 fs/dcache.c:796
[<      none      >] __fput+0x42f/0x780 fs/file_table.c:226
[<      none      >] ____fput+0x15/0x20 fs/file_table.c:244
[<      none      >] task_work_run+0x170/0x210 kernel/task_work.c:115
[<     inline     >] tracehook_notify_resume include/linux/tracehook.h:191
[<      none      >] exit_to_usermode_loop+0x1d1/0x210
arch/x86/entry/common.c:251
[<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:282
[<      none      >] syscall_return_slowpath+0x2ba/0x340
arch/x86/entry/common.c:344
[<      none      >] int_ret_from_sys_call+0x25/0x9f
arch/x86/entry/entry_64.S:281

INFO: Slab 0xffffea0000eda200 objects=22 used=2 fp=0xffff88003b689cc0
flags=0x1fffc0000004080
INFO: Object 0xffff88003b689cc0 @offset=7360 fp=0xffff88003b68a840
CPU: 3 PID: 11997 Comm: syz-executor Tainted: G    B           4.4.0+ #275
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff880038fefb68 ffffffff82994c8d ffff88003df06d00
 ffff88003b689cc0 ffff88003b688000 ffff880038fefb98 ffffffff81755374
 ffff88003df06d00 ffffea0000eda200 ffff88003b689cc0 0000000000000002

Call Trace:
 [<ffffffff8175ea0e>] __asan_report_load8_noabort+0x3e/0x40
mm/kasan/report.c:295
 [<ffffffff851cc31a>] __sys_recvmmsg+0x6fa/0x7f0 net/socket.c:2261
 [<     inline     >] SYSC_recvmmsg net/socket.c:2281
 [<ffffffff851cc57f>] SyS_recvmmsg+0x16f/0x180 net/socket.c:2270
 [<ffffffff86332bb6>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185
==================================================================

I cannot reproduce it, but looking at __sys_recvmmsg code, it seems
that sock is not necessary live after fput_light:

out_put:
    fput_light(sock->file, fput_needed);

    if (err == 0)
        return datagrams;

    if (datagrams != 0) {
        /*
         * We may return less entries than requested (vlen) if the
         * sock is non block and there aren't enough datagrams...
         */
        if (err != -EAGAIN) {
            /*
             * ... or  if recvmsg returns an error after we
             * received some datagrams, where we record the
             * error to return on the next call or if the
             * app asks about it using getsockopt(SO_ERROR).
             */
            sock->sk->sk_err = -err;
        }

        return datagrams;
    }

    return err;
}

I am on commit 30f05309bde49295e02e45c7e615f73aa4e0ccc2 (Jan 20).
Seems to be added in commit a2e2725541fad72416326798c2d7fa4dafb7d337
(Oct 2009).
