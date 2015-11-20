From: Sasha Levin <sasha.levin@oracle.com>
Subject: tty,net: use-after-free in x25_asy_open_tty
Date: Fri, 20 Nov 2015 08:56:53 -0500
Message-ID: <564F26A5.4050905@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, syzkaller@googlegroups.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Peter Hurley <peter@hurleysoftware.com>
To: gregkh@linuxfoundation.org, Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

While fuzzing with syzkaller inside a kvmtools guest running latest -next kernel, I've hit:

[  634.336761] ==================================================================
[  634.338226] BUG: KASAN: use-after-free in x25_asy_open_tty+0x13d/0x490 at addr ffff8800a743efd0
[  634.339558] Read of size 4 by task syzkaller_execu/8981
[  634.340359] =============================================================================
[  634.341598] BUG kmalloc-512 (Not tainted): kasan: bad access detected
[  634.342605] -----------------------------------------------------------------------------
[  634.342605]
[  634.344196] Disabling lock debugging due to kernel taint
[  634.345046] INFO: Allocated in r3964_open+0x55/0x590 age=3 cpu=0 pid=8981
[  634.346165]  ___slab_alloc+0x434/0x5b0
[  634.346912]  __slab_alloc.isra.37+0x79/0xd0
[  634.347642]  kmem_cache_alloc_trace+0xf5/0x350
[  634.348398]  r3964_open+0x55/0x590
[  634.348952]  tty_ldisc_open.isra.2+0x8a/0xd0
[  634.349616]  tty_set_ldisc+0x344/0x910
[  634.350202]  tty_ioctl+0x1534/0x1d70
[  634.350762]  do_vfs_ioctl+0xc90/0xd40
[  634.351349]  SyS_ioctl+0x6d/0xb0
[  634.351890]  entry_SYSCALL_64_fastpath+0x35/0x9e
[  634.352548] INFO: Freed in r3964_close+0x23b/0x280 age=10 cpu=0 pid=8981
[  634.353599]  __slab_free+0x64/0x260
[  634.354151]  kfree+0x281/0x2f0
[  634.354641]  r3964_close+0x23b/0x280
[  634.355219]  tty_ldisc_close.isra.1+0xc2/0xd0
[  634.355890]  tty_set_ldisc+0x2bd/0x910
[  634.356559]  tty_ioctl+0x1534/0x1d70
[  634.357121]  do_vfs_ioctl+0xc90/0xd40
[  634.357614]  SyS_ioctl+0x6d/0xb0
[  634.358133]  entry_SYSCALL_64_fastpath+0x35/0x9e
[  634.358853] INFO: Slab 0xffffea00029d0f00 objects=20 used=10 fp=0xffff8800a743efd0 flags=0x1fffff80004080
[  634.360308] INFO: Object 0xffff8800a743efd0 @offset=12240 fp=0xffff8800a743f300
[  634.360308]
[  634.361652] Bytes b4 ffff8800a743efc0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  634.363048] Object ffff8800a743efd0: 00 f3 43 a7 00 88 ff ff ff ff ff ff 00 00 00 00  ..C.............
[  634.364424] Object ffff8800a743efe0: ff ff ff ff ff ff ff ff a0 7d 41 ab ff ff ff ff  .........}A.....
[  634.365835] Object ffff8800a743eff0: a0 cf a8 a9 ff ff ff ff 00 00 00 00 00 00 00 00  ................
[  634.367346] Object ffff8800a743f000: 00 e8 33 a4 ff ff ff ff 03 00 00 00 00 00 00 00  ..3.............
[  634.368721] Object ffff8800a743f010: 3e a2 5b 9c ff ff ff ff 80 c9 d6 b4 00 88 ff ff  >.[.............
[  634.370139] Object ffff8800a743f020: 00 79 7a 6b 61 6c 6c 65 00 80 50 a7 00 88 ff ff  .yzkalle..P.....
[  634.371635] Object ffff8800a743f030: 20 e7 50 a7 00 88 ff ff 00 00 00 00 00 00 00 00   .P.............
[  634.373000] Object ffff8800a743f040: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  634.374418] Object ffff8800a743f050: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  634.375843] Object ffff8800a743f060: 00 00 00 00 00 00 00 00 01 00 00 00 67 6d c1 1b  ............gm..
[  634.377339] Object ffff8800a743f070: 00 00 00 00 ad 4e ad de ff ff ff ff ad 4e ad de  .....N.......N..
[  634.378747] Object ffff8800a743f080: ff ff ff ff ff ff ff ff a0 48 2c a9 ff ff ff ff  .........H,.....
[  634.380174] Object ffff8800a743f090: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  634.381584] Object ffff8800a743f0a0: c0 21 cd a3 ff ff ff ff 03 00 00 00 00 00 00 00  .!..............
[  634.382949] Object ffff8800a743f0b0: 00 00 00 00 01 00 00 00 b8 f0 43 a7 00 88 ff ff  ..........C.....
[  634.384365] Object ffff8800a743f0c0: b8 f0 43 a7 00 88 ff ff 00 00 00 00 00 00 00 00  ..C.............
[  634.385637] Object ffff8800a743f0d0: 68 f0 43 a7 00 88 ff ff 60 7d 41 ab ff ff ff ff  h.C.....`}A.....
[  634.387138] Object ffff8800a743f0e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  634.388563] Object ffff8800a743f0f0: 40 e8 33 a4 ff ff ff ff 01 00 00 00 00 00 00 00  @.3.............
[  634.389977] Object ffff8800a743f100: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  634.391396] Object ffff8800a743f110: 00 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00  ................
[  634.392868] Object ffff8800a743f120: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  634.393649] Object ffff8800a743f130: c0 73 5b 9c ff ff ff ff d0 ef 43 a7 00 88 ff ff  .s[.......C.....
[  634.394483] Object ffff8800a743f140: 00 00 00 00 ff ff ff ff ff ff ff ff 00 00 00 00  ................
[  634.395281] Object ffff8800a743f150: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  634.396081] Object ffff8800a743f160: 00 00 00 00 00 00 00 00 20 7d 41 ab ff ff ff ff  ........ }A.....
[  634.396928] Object ffff8800a743f170: b0 cd a8 a9 ff ff ff ff 00 00 00 00 00 00 00 00  ................
[  634.397714] Object ffff8800a743f180: 80 e8 33 a4 ff ff ff ff 00 00 00 00 00 00 00 00  ..3.............
[  634.398511] Object ffff8800a743f190: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  634.399314] Object ffff8800a743f1a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  634.400128] Object ffff8800a743f1b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  634.401006] Object ffff8800a743f1c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[  634.401785] CPU: 0 PID: 8981 Comm: syzkaller_execu Tainted: G    B           4.4.0-rc1-next-20151119-sasha-00042-g10467c3 #2643
[  634.402861]  0000000000000000 0000000058ca1c30 ffff8800a4d87970 ffffffff9be4f37b
[  634.403518]  ffff88012f605040 ffff8800a743efd0 ffff8800a743c000 ffff8800a4d879a0
[  634.404198]  ffffffff9a79bf5a ffff88012f605040 ffffea00029d0f00 ffff8800a743efd0
[  634.405018] Call Trace:
[  634.405277] dump_stack (lib/dump_stack.c:52)
[  634.405775] print_trailer (mm/slub.c:655)
[  634.406361] object_err (mm/slub.c:662)
[  634.406824] kasan_report_error (mm/kasan/report.c:138 mm/kasan/report.c:236)
[  634.409581] __asan_report_load4_noabort (mm/kasan/report.c:279)
[  634.411355] x25_asy_open_tty (drivers/net/wan/x25_asy.c:559 (discriminator 1))
[  634.413997] tty_ldisc_open.isra.2 (drivers/tty/tty_ldisc.c:447)
[  634.414549] tty_set_ldisc (drivers/tty/tty_ldisc.c:567)
[  634.415057] tty_ioctl (drivers/tty/tty_io.c:2646 drivers/tty/tty_io.c:2879)
[  634.423524] do_vfs_ioctl (fs/ioctl.c:43 fs/ioctl.c:607)
[  634.427491] SyS_ioctl (fs/ioctl.c:622 fs/ioctl.c:613)
[  634.427945] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:188)
[  634.428475] Memory state around the buggy address:
[  634.428900]  ffff8800a743ee80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  634.429500]  ffff8800a743ef00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[  634.430138] >ffff8800a743ef80: fc fc fc fc fc fc fc fc fc fc fb fb fb fb fb fb
[  634.430780]                                                  ^
[  634.431309]  ffff8800a743f000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[  634.431945]  ffff8800a743f080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[  634.432726] ==================================================================
