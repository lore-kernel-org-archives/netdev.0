From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: Use-after-free/out-of-bounds in tipc filter_rcv()
Date: Tue, 22 Dec 2015 12:22:37 +0100
Message-ID: <5679327D.5050503@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

On latest linus/master I'm able to trigger the following KASAN warnings:

==================================================================
BUG: KASAN: out-of-bounds in filter_rcv+0xc3/0xa10 at addr ffff880014b4d680
Read of size 4 by task a.out/992
=============================================================================
BUG sock_inode_cache (Not tainted): kasan: bad access detected
-----------------------------------------------------------------------------

Disabling lock debugging due to kernel taint
INFO: Allocated in sock_alloc_inode+0x20/0x140 age=0 cpu=0 pid=991
	___slab_alloc+0x724/0x810
	__slab_alloc.isra.49+0x86/0xc0
	kmem_cache_alloc+0x25a/0x2d0
	sock_alloc_inode+0x20/0x140
	alloc_inode+0x35/0x110
	new_inode_pseudo+0x14/0xa0
	sock_alloc+0x2e/0x110
	__sock_create+0xb1/0x280
	SyS_socket+0xcd/0x160
	entry_SYSCALL_64_fastpath+0x12/0x71
INFO: Freed in sock_destroy_inode+0x49/0x60 age=0 cpu=0 pid=991
	__slab_free+0x1f0/0x360
	kmem_cache_free+0x2b6/0x300
	sock_destroy_inode+0x49/0x60
	destroy_inode+0x73/0xc0
	evict+0x231/0x350
	iput+0x311/0x500
	__dentry_kill+0x332/0x410
	dput+0x400/0x4c0
	__fput+0x291/0x3c0
	____fput+0x11/0x20
	task_work_run+0xfc/0x140
	exit_to_usermode_loop+0xe1/0x130
	syscall_return_slowpath+0x9c/0xb0
	int_ret_from_sys_call+0x25/0x8f
INFO: Slab 0xffffea000052d300 objects=17 used=13 fp=0xffff880014b4e580 
flags=0x100000000004080
INFO: Object 0xffff880014b4d680 @offset=5760 fp=0xffff880014b4f0c0

Bytes b4 ffff880014b4d670: 8e 17 79 56 00 00 00 00 ca 94 7b 10 00 00 00 
00  ..yV......{.....
Object ffff880014b4d680: 04 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d690: c0 5c 9b 13 00 88 ff ff 00 00 00 00 00 00 00 00 
  .\..............
Object ffff880014b4d6a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d6b0: ff c1 04 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d6c0: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
  ................
Object ffff880014b4d6d0: 00 c0 92 82 ff ff ff ff 00 80 c0 15 00 88 ff ff 
  ................
Object ffff880014b4d6e0: 08 d8 b4 14 00 88 ff ff 80 61 9b 13 00 88 ff ff 
  .........a......
Object ffff880014b4d6f0: af 16 6a 00 00 00 00 00 01 00 00 00 00 00 00 00 
  ..j.............
Object ffff880014b4d700: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d710: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d720: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d730: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d740: 0c 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d750: 60 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 
  `...............
Object ffff880014b4d760: 60 d7 b4 14 00 88 ff ff 60 d7 b4 14 00 88 ff ff 
  `.......`.......
Object ffff880014b4d770: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d780: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d790: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d7a0: a0 d7 b4 14 00 88 ff ff a0 d7 b4 14 00 88 ff ff 
  ................
Object ffff880014b4d7b0: b0 d7 b4 14 00 88 ff ff b0 d7 b4 14 00 88 ff ff 
  ................
Object ffff880014b4d7c0: c0 d7 b4 14 00 88 ff ff c0 d7 b4 14 00 88 ff ff 
  ................
Object ffff880014b4d7d0: 60 ea ae 14 00 88 ff ff 00 00 00 00 00 00 00 00 
  `...............
Object ffff880014b4d7e0: 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d7f0: 00 00 00 00 00 00 00 00 80 26 69 82 ff ff ff ff 
  .........&i.....
Object ffff880014b4d800: 00 00 00 00 00 00 00 00 b0 d6 b4 14 00 88 ff ff 
  ................
Object ffff880014b4d810: 00 00 00 00 20 00 08 02 00 00 00 00 00 00 00 00 
  .... ...........
Object ffff880014b4d820: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d830: 00 00 00 00 00 00 00 00 38 d8 b4 14 00 88 ff ff 
  ........8.......
Object ffff880014b4d840: 38 d8 b4 14 00 88 ff ff 00 00 00 00 00 00 00 00 
  8...............
Object ffff880014b4d850: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d860: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d870: 80 27 69 82 ff ff ff ff ca 00 42 42 00 00 00 00 
  .'i.......BB....
Object ffff880014b4d880: 00 00 00 00 00 00 00 00 88 d8 b4 14 00 88 ff ff 
  ................
Object ffff880014b4d890: 88 d8 b4 14 00 88 ff ff 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d8a0: a0 d8 b4 14 00 88 ff ff a0 d8 b4 14 00 88 ff ff 
  ................
Object ffff880014b4d8b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d8c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Padding ffff880014b4da08: dd c5 4d 2e 00 00 00 00 b2 89 75 56 00 00 00 
00  ..M.......uV....
Padding ffff880014b4da18: 5a b0 97 27 00 00 00 00 b2 89 75 56 00 00 00 
00  Z..'......uV....
Padding ffff880014b4da28: 5a b0 97 27 00 00 00 00 00 00 00 00 00 00 00 
00  Z..'............
Padding ffff880014b4da38: 0d 00 00 00 00 00 00 00 
    ........
CPU: 2 PID: 992 Comm: a.out Tainted: G    B           4.4.0-rc5+ #109
  ffffea000052d300 ffff8800139778f0 ffffffff8169ed5b ffff8800165ed600
  ffff880013977920 ffffffff812e36ec ffff8800165ed600 ffffea000052d300
  ffff880014b4d680 ffff8800139f24d0 ffff880013977948 ffffffff812e946f
Call Trace:
  [<ffffffff8169ed5b>] dump_stack+0x8d/0xe2
  [<ffffffff812e36ec>] print_trailer+0x13c/0x1b0
  [<ffffffff812e946f>] object_err+0x3f/0x50
  [<ffffffff812f02c3>] kasan_report_error+0x2e3/0x6e0
  [<ffffffff811683f0>] ? rcu_read_unlock_special+0x560/0x610
  [<ffffffff812f0704>] kasan_report+0x44/0x50
  [<ffffffff82407f73>] ? filter_rcv+0xc3/0xa10
  [<ffffffff812ef226>] __asan_load4+0x96/0xf0
  [<ffffffff82407f73>] filter_rcv+0xc3/0xa10
  [<ffffffff8240bf73>] tipc_sk_rcv+0x7e3/0xb60
  [<ffffffff8240b790>] ? tipc_send_packet+0x40/0x40
  [<ffffffff8100ec0b>] ? print_context_stack+0xab/0x130
  [<ffffffff8115c798>] ? __rcu_read_unlock+0x88/0xc0
  [<ffffffff8115c798>] ? __rcu_read_unlock+0x88/0xc0
  [<ffffffff82400c8b>] tipc_node_xmit+0x23b/0x290
  [<ffffffff82400a50>] ? tipc_node_add_conn+0x1b0/0x1b0
  [<ffffffff823f10a3>] ? tipc_msg_reverse+0x393/0x550
  [<ffffffff82400d9a>] tipc_node_xmit_skb+0xba/0x110
  [<ffffffff82400ce0>] ? tipc_node_xmit+0x290/0x290
  [<ffffffff812e7dd1>] ? __slab_free+0x81/0x360
  [<ffffffff811302c1>] ? __raw_callee_save___pv_queued_spin_unlock+0x11/0x20
  [<ffffffff824071ea>] tipc_sk_respond+0x13a/0x170
  [<ffffffff82407d35>] tipc_release+0x6e5/0x860
  [<ffffffff81e67803>] sock_release+0x43/0xe0
  [<ffffffff81e67d45>] sock_close+0x15/0x30
  [<ffffffff8130067f>] __fput+0x16f/0x3c0
  [<ffffffff813008e1>] ____fput+0x11/0x20
  [<ffffffff810ea84c>] task_work_run+0xfc/0x140
  [<ffffffff810024f1>] exit_to_usermode_loop+0xe1/0x130
  [<ffffffff81003d5c>] syscall_return_slowpath+0x9c/0xb0
  [<ffffffff824cf14c>] int_ret_from_sys_call+0x25/0x8f
Memory state around the buggy address:
  ffff880014b4d580: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
  ffff880014b4d600: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 >ffff880014b4d680: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                       ^
  ffff880014b4d700: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff880014b4d780: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================
==================================================================
BUG: KASAN: use-after-free in filter_rcv+0x144/0xa10 at addr 
ffff880014b4d680
Read of size 4 by task a.out/992
=============================================================================
BUG sock_inode_cache (Tainted: G    B          ): kasan: bad access detected
-----------------------------------------------------------------------------

INFO: Allocated in sock_alloc_inode+0x20/0x140 age=31 cpu=3 pid=989
	___slab_alloc+0x724/0x810
	__slab_alloc.isra.49+0x86/0xc0
	kmem_cache_alloc+0x25a/0x2d0
	sock_alloc_inode+0x20/0x140
	alloc_inode+0x35/0x110
	new_inode_pseudo+0x14/0xa0
	sock_alloc+0x2e/0x110
	__sock_create+0xb1/0x280
	SyS_accept4+0x11/0x20
	entry_SYSCALL_64_fastpath+0x12/0x71
INFO: Freed in sock_destroy_inode+0x49/0x60 age=0 cpu=1 pid=988
	__slab_free+0x1f0/0x360
	kmem_cache_free+0x2b6/0x300
	sock_destroy_inode+0x49/0x60
	destroy_inode+0x73/0xc0
	evict+0x231/0x350
	iput+0x311/0x500
	__dentry_kill+0x332/0x410
	dput+0x400/0x4c0
	__fput+0x291/0x3c0
	____fput+0x11/0x20
	task_work_run+0xfc/0x140
	exit_to_usermode_loop+0xe1/0x130
	syscall_return_slowpath+0x9c/0xb0
	int_ret_from_sys_call+0x25/0x8f
INFO: Slab 0xffffea000052d300 objects=17 used=13 fp=0xffff880014b4f0c0 
flags=0x100000000004080
INFO: Object 0xffff880014b4d680 @offset=5760 fp=0xffff880014b4cb40

Bytes b4 ffff880014b4d670: 8e 17 79 56 00 00 00 00 ca 94 7b 10 00 00 00 
00  ..yV......{.....
Object ffff880014b4d680: 04 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d690: d0 0f a9 13 00 88 ff ff 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d6a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d6b0: ff c1 04 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d6c0: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
  ................
Object ffff880014b4d6d0: 00 c0 92 82 ff ff ff ff 00 80 c0 15 00 88 ff ff 
  ................
Object ffff880014b4d6e0: 08 d8 b4 14 00 88 ff ff 80 33 a9 13 00 88 ff ff 
  .........3......
Object ffff880014b4d6f0: 2a 13 6a 00 00 00 00 00 01 00 00 00 00 00 00 00 
  *.j.............
Object ffff880014b4d700: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d710: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d720: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d730: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d740: 0c 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d750: 60 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 
  `...............
Object ffff880014b4d760: 60 d7 b4 14 00 88 ff ff 60 d7 b4 14 00 88 ff ff 
  `.......`.......
Object ffff880014b4d770: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d780: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d790: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d7a0: a0 d7 b4 14 00 88 ff ff a0 d7 b4 14 00 88 ff ff 
  ................
Object ffff880014b4d7b0: b0 d7 b4 14 00 88 ff ff b0 d7 b4 14 00 88 ff ff 
  ................
Object ffff880014b4d7c0: c0 d7 b4 14 00 88 ff ff c0 d7 b4 14 00 88 ff ff 
  ................
Object ffff880014b4d7d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d7e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d7f0: 00 00 00 00 00 00 00 00 80 26 69 82 ff ff ff ff 
  .........&i.....
Object ffff880014b4d800: 00 00 00 00 00 00 00 00 b0 d6 b4 14 00 88 ff ff 
  ................
Object ffff880014b4d810: 00 00 00 00 20 00 08 02 00 00 00 00 00 00 00 00 
  .... ...........
Object ffff880014b4d820: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d830: 00 00 00 00 00 00 00 00 38 d8 b4 14 00 88 ff ff 
  ........8.......
Object ffff880014b4d840: 38 d8 b4 14 00 88 ff ff 00 00 00 00 00 00 00 00 
  8...............
Object ffff880014b4d850: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d860: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d870: 80 27 69 82 ff ff ff ff ca 00 42 42 00 00 00 00 
  .'i.......BB....
Object ffff880014b4d880: 00 00 00 00 00 00 00 00 88 d8 b4 14 00 88 ff ff 
  ................
Object ffff880014b4d890: 88 d8 b4 14 00 88 ff ff 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d8a0: a0 d8 b4 14 00 88 ff ff a0 d8 b4 14 00 88 ff ff 
  ................
Object ffff880014b4d8b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Object ffff880014b4d8c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  ................
Padding ffff880014b4da08: dd c5 4d 2e 00 00 00 00 b2 89 75 56 00 00 00 
00  ..M.......uV....
Padding ffff880014b4da18: 5a b0 97 27 00 00 00 00 b2 89 75 56 00 00 00 
00  Z..'......uV....
Padding ffff880014b4da28: 5a b0 97 27 00 00 00 00 00 00 00 00 00 00 00 
00  Z..'............
Padding ffff880014b4da38: 0d 00 00 00 00 00 00 00 
    ........
CPU: 2 PID: 992 Comm: a.out Tainted: G    B           4.4.0-rc5+ #109
  ffffea000052d300 ffff8800139778f0 ffffffff8169ed5b ffff8800165ed600
  ffff880013977920 ffffffff812e36ec ffff8800165ed600 ffffea000052d300
  ffff880014b4d680 ffff88001399ad30 ffff880013977948 ffffffff812e946f
Call Trace:
  [<ffffffff8169ed5b>] dump_stack+0x8d/0xe2
  [<ffffffff812e36ec>] print_trailer+0x13c/0x1b0
  [<ffffffff812e946f>] object_err+0x3f/0x50
  [<ffffffff812f02c3>] kasan_report_error+0x2e3/0x6e0
  [<ffffffff812f0704>] kasan_report+0x44/0x50
  [<ffffffff82407ff4>] ? filter_rcv+0x144/0xa10
  [<ffffffff812ef226>] __asan_load4+0x96/0xf0
  [<ffffffff82407ff4>] filter_rcv+0x144/0xa10
  [<ffffffff8240bf73>] tipc_sk_rcv+0x7e3/0xb60
  [<ffffffff8240b790>] ? tipc_send_packet+0x40/0x40
  [<ffffffff8100ec0b>] ? print_context_stack+0xab/0x130
  [<ffffffff8115c798>] ? __rcu_read_unlock+0x88/0xc0
  [<ffffffff8115c798>] ? __rcu_read_unlock+0x88/0xc0
  [<ffffffff82400c8b>] tipc_node_xmit+0x23b/0x290
  [<ffffffff82400a50>] ? tipc_node_add_conn+0x1b0/0x1b0
  [<ffffffff823f10a3>] ? tipc_msg_reverse+0x393/0x550
  [<ffffffff82400d9a>] tipc_node_xmit_skb+0xba/0x110
  [<ffffffff82400ce0>] ? tipc_node_xmit+0x290/0x290
  [<ffffffff812e7dd1>] ? __slab_free+0x81/0x360
  [<ffffffff811302c1>] ? __raw_callee_save___pv_queued_spin_unlock+0x11/0x20
  [<ffffffff824071ea>] tipc_sk_respond+0x13a/0x170
  [<ffffffff82407d35>] tipc_release+0x6e5/0x860
  [<ffffffff81e67803>] sock_release+0x43/0xe0
  [<ffffffff81e67d45>] sock_close+0x15/0x30
  [<ffffffff8130067f>] __fput+0x16f/0x3c0
  [<ffffffff813008e1>] ____fput+0x11/0x20
  [<ffffffff810ea84c>] task_work_run+0xfc/0x140
  [<ffffffff810024f1>] exit_to_usermode_loop+0xe1/0x130
  [<ffffffff81003d5c>] syscall_return_slowpath+0x9c/0xb0
  [<ffffffff824cf14c>] int_ret_from_sys_call+0x25/0x8f
Memory state around the buggy address:
  ffff880014b4d580: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
  ffff880014b4d600: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 >ffff880014b4d680: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                    ^
  ffff880014b4d700: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff880014b4d780: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================

(+ many more messages)

The decoded stack trace:

Call Trace:

dump_stack (lib/dump_stack.c:15 lib/dump_stack.c:50)
print_trailer (mm/slub.c:653)
object_err (mm/slub.c:660)
kasan_report_error (mm/kasan/report.c:138 mm/kasan/report.c:236)
? rcu_read_unlock_special (kernel/rcu/tree_plugin.h:501)
kasan_report (mm/kasan/report.c:259)
? filter_rcv (net/tipc/socket.c:1673)
__asan_load4 (mm/kasan/kasan.c:271 mm/kasan/kasan.c:506)
filter_rcv (net/tipc/socket.c:1673)
tipc_sk_rcv (net/tipc/socket.c:1747 net/tipc/socket.c:1786)
? tipc_send_packet (net/tipc/socket.c:1772)
? print_context_stack (arch/x86/kernel/dumpstack.c:107)
? __rcu_read_unlock (kernel/rcu/update.c:205)
? __rcu_read_unlock (kernel/rcu/update.c:205)
tipc_node_xmit (net/tipc/node.c:1050)
? tipc_node_add_conn (net/tipc/node.c:1025)
? tipc_msg_reverse (include/linux/skbuff.h:2215 net/tipc/msg.c:517)
tipc_node_xmit_skb (net/tipc/node.c:1072)
? tipc_node_xmit (net/tipc/node.c:1066)
? __slab_free (mm/slub.c:2692)
? __raw_callee_save___pv_queued_spin_unlock (??:?)
tipc_sk_respond (net/tipc/socket.c:265)
tipc_release (net/tipc/socket.c:458)
sock_release (net/socket.c:572)
sock_close (net/socket.c:1024)
__fput (fs/file_table.c:208)
____fput (fs/file_table.c:244)
task_work_run (kernel/task_work.c:115 (discriminator 1))
exit_to_usermode_loop (include/linux/tracehook.h:191 
arch/x86/entry/common.c:251)
syscall_return_slowpath (arch/x86/entry/common.c:345)
int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)

I strongly suspect a race related to the use of rhashtable as I also
saw something very similar in RDS.

Unfortunately I'm unable to provide a reproducer, but I can test patches.


Vegard
