From: Sasha Levin <sasha.levin@oracle.com>
Subject: fs: use after free in __fput
Date: Tue, 5 Jul 2016 09:44:00 -0400
Message-ID: <577BB9A0.5050104@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I'm seeing the following use-after-free while fuzzing with syzkaller
on the latest -next kernel:

[ 1148.840231] ==================================================================

[ 1148.840335] BUG: KASAN: use-after-free in __fput+0x3db/0x700 at addr ffff8801bb4bc070

[ 1148.840347] Read of size 2 by task syz-executor/1927

[ 1148.840354] =============================================================================

[ 1148.840365] BUG sock_inode_cache (Not tainted): kasan: bad access detected

[ 1148.840368] -----------------------------------------------------------------------------

[ 1148.840368]

[ 1148.840374] Disabling lock debugging due to kernel taint

[ 1148.840384] INFO: Allocated in 0xffff8801bb4bc280 age=6071073280 cpu=2519709157 pid=-1

[ 1148.840397] INFO: Freed in do_vfs_ioctl+0x107c/0x1110 age=6216578324 cpu=2374204086 pid=-1

[ 1148.840402] 	SyS_ioctl+0x68/0xb0

[ 1148.840430] 	do_syscall_64+0x2a6/0x490

[ 1148.840478] 	return_from_SYSCALL_64+0x0/0x6a

[ 1148.840485] INFO: Slab 0xffffea0006ed2f00 objects=16 used=10 fp=0xffff8801bb4bc040 flags=0x2fffff80004080

[ 1148.840490] INFO: Object 0xffff8801bb4bc000 @offset=0 fp=0xffff8801bb4bc280

[ 1148.840490]

[ 1148.840508] Redzone ffff8801bb4bbfc0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840515] Redzone ffff8801bb4bbfd0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840521] Redzone ffff8801bb4bbfe0: 00 00 00 00 00 00 00 00 04 00 00 00 34 30 00 00  ............40..

[ 1148.840527] Redzone ffff8801bb4bbff0: 04 e6 fd ff 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840533] Object ffff8801bb4bc000: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................

[ 1148.840540] Object ffff8801bb4bc010: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................

[ 1148.840546] Object ffff8801bb4bc020: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................

[ 1148.840552] Object ffff8801bb4bc030: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................

[ 1148.840558] Object ffff8801bb4bc040: 01 00 00 00 02 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840564] Object ffff8801bb4bc050: 00 97 37 b9 01 88 ff ff 00 00 00 00 00 00 00 00  ..7.............

[ 1148.840570] Object ffff8801bb4bc060: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840576] Object ffff8801bb4bc070: ff c1 04 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840585] Object ffff8801bb4bc080: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................

[ 1148.840592] Object ffff8801bb4bc090: c0 bb 53 99 ff ff ff ff 68 6f 4e d1 01 88 ff ff  ..S.....hoN.....

[ 1148.840598] Object ffff8801bb4bc0a0: e8 c1 4b bb 01 88 ff ff 00 00 00 00 00 00 00 00  ..K.............

[ 1148.840605] Object ffff8801bb4bc0b0: 58 c3 02 00 00 00 00 00 01 00 00 00 00 00 00 00  X...............

[ 1148.840611] Object ffff8801bb4bc0c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840617] Object ffff8801bb4bc0d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840623] Object ffff8801bb4bc0e0: 00 00 00 00 00 00 00 00 bb a6 7b 57 00 00 00 00  ..........{W....

[ 1148.840629] Object ffff8801bb4bc0f0: 9a e9 bc 11 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840635] Object ffff8801bb4bc100: 0c 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840641] Object ffff8801bb4bc110: 60 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  `...............

[ 1148.840647] Object ffff8801bb4bc120: 20 c1 4b bb 01 88 ff ff 20 c1 4b bb 01 88 ff ff   .K..... .K.....

[ 1148.840653] Object ffff8801bb4bc130: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840659] Object ffff8801bb4bc140: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840665] Object ffff8801bb4bc150: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840671] Object ffff8801bb4bc160: 60 c1 4b bb 01 88 ff ff 60 c1 4b bb 01 88 ff ff  `.K.....`.K.....

[ 1148.840681] Object ffff8801bb4bc170: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840687] Object ffff8801bb4bc180: 80 c1 4b bb 01 88 ff ff 80 c1 4b bb 01 88 ff ff  ..K.......K.....

[ 1148.840693] Object ffff8801bb4bc190: 90 c1 4b bb 01 88 ff ff 90 c1 4b bb 01 88 ff ff  ..K.......K.....

[ 1148.840699] Object ffff8801bb4bc1a0: a0 c1 4b bb 01 88 ff ff a0 c1 4b bb 01 88 ff ff  ..K.......K.....

[ 1148.840706] Object ffff8801bb4bc1b0: 60 2b 82 b1 00 88 ff ff 00 00 00 00 00 00 00 00  `+..............

[ 1148.840712] Object ffff8801bb4bc1c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840718] Object ffff8801bb4bc1d0: 00 00 00 00 00 00 00 00 c0 8d 93 97 ff ff ff ff  ................

[ 1148.840724] Object ffff8801bb4bc1e0: 00 00 00 00 00 00 00 00 70 c0 4b bb 01 88 ff ff  ........p.K.....

[ 1148.840730] Object ffff8801bb4bc1f0: 20 00 08 02 00 00 00 00 00 00 00 00 00 00 00 00   ...............

[ 1148.840736] Object ffff8801bb4bc200: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840742] Object ffff8801bb4bc210: 00 00 00 00 00 00 00 00 18 c2 4b bb 01 88 ff ff  ..........K.....

[ 1148.840748] Object ffff8801bb4bc220: 18 c2 4b bb 01 88 ff ff 00 00 00 00 00 00 00 00  ..K.............

[ 1148.840754] Object ffff8801bb4bc230: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840761] Object ffff8801bb4bc240: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1148.840767] Object ffff8801bb4bc250: e0 8e 93 97 ff ff ff ff ca 00 42 42 00 00 00 00  ..........BB....

[ 1148.840773] Object ffff8801bb4bc260: 00 00 00 00 00 00 00 00 68 c2 4b bb 01 88 ff ff  ........h.K.....

[ 1148.840778] Object ffff8801bb4bc270: 68 c2 4b bb 01 88 ff ff                          h.K.....

[ 1148.840784] Redzone ffff8801bb4bc278: 00 00 00 00 00 00 00 00                          ........

[ 1148.840790] Padding ffff8801bb4bc3b8: 20 33 3f 8d ff ff ff ff                           3?.....

[ 1148.840807] CPU: 4 PID: 1927 Comm: syz-executor Tainted: G    B           4.7.0-rc5-next-20160704-sasha-00025-g70e95e1 #3153

[ 1148.840830]  1ffff10036fb4ef5 000000003e041c12 ffff8801b7da7830 ffffffff8f06c087

[ 1148.840839]  ffffffff00000004 fffffbfff34b1f60 0000000041b58ab3 ffffffff99d08198

[ 1148.840847]  ffffffff8f06bf18 000000003e041c12 ffff8801b917c000 ffffffff99d26de4

[ 1148.840848] Call Trace:

[ 1148.840884] dump_stack (lib/dump_stack.c:53)
[ 1148.840930] print_trailer (mm/slub.c:668)
[ 1148.840939] object_err (mm/slub.c:675)
[ 1148.840946] kasan_report_error (mm/kasan/report.c:180 mm/kasan/report.c:276)
[ 1148.841010] __asan_report_load2_noabort (mm/kasan/report.c:317)
[ 1148.841026] __fput (fs/file_table.c:210)
[ 1148.841034] ____fput (fs/file_table.c:245)
[ 1148.841051] task_work_run (kernel/task_work.c:118 (discriminator 1))
[ 1148.841065] do_exit (kernel/exit.c:829)
[ 1148.841073] ? mm_update_next_owner (kernel/exit.c:729)
[ 1148.841083] ? __dequeue_signal (kernel/signal.c:545)
[ 1148.841090] do_group_exit (kernel/exit.c:958)
[ 1148.841097] get_signal (kernel/signal.c:2307)
[ 1148.841112] do_signal (arch/x86/kernel/signal.c:783)
[ 1148.841225] exit_to_usermode_loop (arch/x86/entry/common.c:165)
[ 1148.841233] do_syscall_64 (arch/x86/entry/common.c:208 arch/x86/entry/common.c:263 arch/x86/entry/common.c:289)
[ 1148.841251] entry_SYSCALL64_slow_path (arch/x86/entry/entry_64.S:251)
[ 1148.841254] Memory state around the buggy address:

[ 1148.841260]  ffff8801bb4bbf00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

[ 1148.841266]  ffff8801bb4bbf80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

[ 1148.841271] >ffff8801bb4bc000: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb

[ 1148.841274]                                                              ^

[ 1148.841280]  ffff8801bb4bc080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb

[ 1148.841286]  ffff8801bb4bc100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb

[ 1148.841287] ==================================================================


Thanks,
Sasha
