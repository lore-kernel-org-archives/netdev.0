From: Dmitry Vyukov <dvyukov@google.com>
Subject: net/irda: BUG: looking up invalid subclass: 4294967295
Date: Thu, 4 Feb 2016 10:13:43 +0100
Message-ID: <CACT4Y+a8=L9m3c1PvGDm9Tr_C3cN79bjnjT581i2k+7MVLzZTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am hitting the following BUGs while running syzkaller fuzzer:

BUG: looking up invalid subclass: 4294967295
turning off the locking correctness validator.
CPU: 1 PID: 12344 Comm: syz-executor Not tainted 4.5.0-rc2+ #309
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff88005dcff4a0 ffffffff82be2c8d ffff88006c9b17c0
 00000000ffffffff 0000000000000001 ffff88005dcff630 ffffffff81457780
 ffff88005dcffff8 ffff88005dcf8000 00000000000015f0 ffffffffffff8000
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff82be2c8d>] dump_stack+0x6f/0xa2 lib/dump_stack.c:50
 [<     inline     >] look_up_lock_class kernel/locking/lockdep.c:694
 [<     inline     >] register_lock_class kernel/locking/lockdep.c:752
 [<ffffffff81457780>] __lock_acquire+0x1110/0x4700 kernel/locking/lockdep.c:3103
 [<ffffffff8145d1bc>] lock_acquire+0x1dc/0x430 kernel/locking/lockdep.c:3587
 [<ffffffff8665e105>] _raw_spin_lock_irqsave_nested+0xa5/0xd0
kernel/locking/spinlock.c:381
 [<ffffffff85cfcff1>] hashbin_delete+0x1b1/0x260 net/irda/irqueue.c:400
 [<ffffffff85d071fb>] __irias_delete_object+0xab/0x170
net/irda/irias_object.c:111
 [<ffffffff85d07331>] irias_delete_object+0x71/0xf0 net/irda/irias_object.c:139
 [<ffffffff85d385b5>] ircomm_tty_detach_cable+0x1d5/0x3f0
net/irda/ircomm/ircomm_tty_attach.c:185
 [<ffffffff85d33d4b>] ircomm_tty_shutdown+0x9b/0x2b0
net/irda/ircomm/ircomm_tty.c:883
 [<ffffffff85d349b7>] ircomm_tty_close+0xa7/0x140
net/irda/ircomm/ircomm_tty.c:489
 [<ffffffff82f85c9d>] tty_release+0x37d/0x1290 drivers/tty/tty_io.c:1793
 [<ffffffff82f881a2>] tty_open+0x3a2/0x1070 drivers/tty/tty_io.c:2117
 [<ffffffff817c864a>] chrdev_open+0x22a/0x4c0 fs/char_dev.c:388
 [<ffffffff817b3e72>] do_dentry_open+0x6a2/0xcb0 fs/open.c:736
 [<ffffffff817b754b>] vfs_open+0x17b/0x1f0 fs/open.c:853
 [<     inline     >] do_last fs/namei.c:3254
 [<ffffffff817ead19>] path_openat+0xde9/0x5e30 fs/namei.c:3386
 [<ffffffff817f359e>] do_filp_open+0x18e/0x250 fs/namei.c:3421
 [<ffffffff817b7ccc>] do_sys_open+0x1fc/0x420 fs/open.c:1022
 [<     inline     >] SYSC_open fs/open.c:1040
 [<ffffffff817b7f1d>] SyS_open+0x2d/0x40 fs/open.c:1035


hashbin_delete() seems to maintain hashbin_lock_depth variable in a
completely thread-unsafe way. hashbin_lock_depth needs to be per-task
or something.

I am on commit 34229b277480f46c1e9a19f027f30b074512e68b.
