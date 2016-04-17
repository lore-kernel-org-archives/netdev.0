From: Sasha Levin <sasha.levin@oracle.com>
Subject: bpf: use-after-free in array_map_alloc
Date: Sun, 17 Apr 2016 12:58:21 -0400
Message-ID: <5713C0AD.3020102@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: ast@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39933 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588AbcDQQ63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2016 12:58:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I've hit the following while fuzzing with syzkaller inside a KVM tools guest
running the latest -next kernel:

[ 2590.845375] ==================================================================

[ 2590.845445] BUG: KASAN: use-after-free in pcpu_extend_area_map+0x8a/0x130 at addr ffff88035452a3cc

[ 2590.845457] Read of size 4 by task syz-executor/31307

[ 2590.845464] =============================================================================

[ 2590.845476] BUG kmalloc-128 (Tainted: G        W      ): kasan: bad access detected

[ 2590.845479] -----------------------------------------------------------------------------

[ 2590.845479]

[ 2590.845485] Disabling lock debugging due to kernel taint

[ 2590.845496] INFO: Allocated in 0xbbbbbbbbbbbbbbbb age=18446609615465671625 cpu=0 pid=0

[ 2590.845504] 	pcpu_mem_zalloc+0x7e/0xc0

[ 2590.845521] 	___slab_alloc+0x7af/0x870

[ 2590.845528] 	__slab_alloc.isra.22+0xf4/0x130

[ 2590.845535] 	__kmalloc+0x1fe/0x340

[ 2590.845543] 	pcpu_mem_zalloc+0x7e/0xc0

[ 2590.845551] 	pcpu_create_chunk+0x79/0x600

[ 2590.845558] 	pcpu_alloc+0x5d4/0xe10

[ 2590.845567] 	__alloc_percpu_gfp+0x27/0x30

[ 2590.845582] 	array_map_alloc+0x595/0x710

[ 2590.845590] 	SyS_bpf+0x336/0xba0

[ 2590.845605] 	do_syscall_64+0x2a6/0x4a0

[ 2590.845639] 	return_from_SYSCALL_64+0x0/0x6a

[ 2590.845647] INFO: Freed in 0x10022ebb3 age=18446628393062689737 cpu=0 pid=0

[ 2590.845653] 	kvfree+0x45/0x50

[ 2590.845660] 	__slab_free+0x6a/0x2f0

[ 2590.845665] 	kfree+0x22c/0x270

[ 2590.845671] 	kvfree+0x45/0x50

[ 2590.845680] 	pcpu_balance_workfn+0x11a1/0x1280

[ 2590.845693] 	process_one_work+0x973/0x10b0

[ 2590.845700] 	worker_thread+0xcfd/0x1160

[ 2590.845708] 	kthread+0x2e7/0x300

[ 2590.845716] 	ret_from_fork+0x22/0x40

[ 2590.845724] INFO: Slab 0xffffea000d514a00 objects=35 used=33 fp=0xffff88035452b740 flags=0x2fffff80004080

[ 2590.845730] INFO: Object 0xffff88035452a3a0 @offset=9120 fp=0xbbbbbbbbbbbbbbbb

[ 2590.845730]

[ 2590.845743] Redzone ffff88035452a398: 00 00 00 00 00 00 00 00                          ........

[ 2590.845751] Object ffff88035452a3a0: bb bb bb bb bb bb bb bb 00 00 00 00 00 00 00 00  ................

[ 2590.845758] Object ffff88035452a3b0: b0 7b 17 3f 03 88 ff ff 00 00 08 00 00 00 08 00  .{.?............

[ 2590.845765] Object ffff88035452a3c0: 00 00 e0 f9 ff e8 ff ff 01 00 00 00 10 00 00 00  ................

[ 2590.845775] Object ffff88035452a3d0: 18 83 2c 3f 03 88 ff ff e0 ff ff ff 0f 00 00 00  ..,?............

[ 2590.845783] Object ffff88035452a3e0: e0 a3 52 54 03 88 ff ff e0 a3 52 54 03 88 ff ff  ..RT......RT....

[ 2590.845790] Object ffff88035452a3f0: 90 96 6b 9f ff ff ff ff e8 a7 13 3f 03 88 ff ff  ..k........?....

[ 2590.845797] Object ffff88035452a400: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 2590.845804] Object ffff88035452a410: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 2590.845811] Redzone ffff88035452a420: 00 00 00 00 00 00 00 00                          ........

[ 2590.845818] Padding ffff88035452a558: b5 eb 22 00 01 00 00 00                          ..".....

[ 2590.845833] CPU: 0 PID: 31307 Comm: syz-executor Tainted: G    B   W       4.6.0-rc3-next-20160412-sasha-00023-g0b02d6d-dirty #2998

[ 2590.845851]  0000000000000000 00000000a66f8039 ffff880354f8fa60 ffffffffa0fc9d01

[ 2590.845861]  ffffffff00000000 fffffbfff57ad2a0 0000000041b58ab3 ffffffffab65eee0

[ 2590.845870]  ffffffffa0fc9b88 00000000a66f8039 ffff88035e9d4000 ffffffffab67cede

[ 2590.845872] Call Trace:

[ 2590.845903] dump_stack (lib/dump_stack.c:53)
[ 2590.845939] print_trailer (mm/slub.c:668)
[ 2590.845948] object_err (mm/slub.c:675)
[ 2590.845958] kasan_report_error (mm/kasan/report.c:180 mm/kasan/report.c:276)
[ 2590.846007] __asan_report_load4_noabort (mm/kasan/report.c:318)
[ 2590.846028] pcpu_extend_area_map (mm/percpu.c:445)
[ 2590.846038] pcpu_alloc (mm/percpu.c:940)
[ 2590.846128] __alloc_percpu_gfp (mm/percpu.c:1068)
[ 2590.846140] array_map_alloc (kernel/bpf/arraymap.c:36 kernel/bpf/arraymap.c:99)
[ 2590.846150] SyS_bpf (kernel/bpf/syscall.c:35 kernel/bpf/syscall.c:183 kernel/bpf/syscall.c:830 kernel/bpf/syscall.c:787)
[ 2590.846203] do_syscall_64 (arch/x86/entry/common.c:350)
[ 2590.846214] entry_SYSCALL64_slow_path (arch/x86/entry/entry_64.S:251)
[ 2590.846217] Memory state around the buggy address:

[ 2590.846224]  ffff88035452a280: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

[ 2590.846230]  ffff88035452a300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

[ 2590.846237] >ffff88035452a380: fc fc fc fc fc fb fb fb fb fb fb fb fb fb fb fb

[ 2590.846240]                                               ^

[ 2590.846247]  ffff88035452a400: fb fb fb fb fb fc fc fc fc fc fc fc fc fc fc fc

[ 2590.846253]  ffff88035452a480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

[ 2590.846256] ==================================================================
