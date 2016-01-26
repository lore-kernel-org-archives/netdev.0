From: Dmitry Vyukov <dvyukov@google.com>
Subject: net/bluetooth: workqueue destruction WARNING in hci_unregister_dev
Date: Tue, 26 Jan 2016 12:53:24 +0100
Message-ID: <CACT4Y+ax7zMOxe+kd4tw5Xdbvt=qPdBhXGO0j7qJwdn5tsfNNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've hit the following warning while running syzkaller fuzzer:

------------[ cut here ]------------
WARNING: CPU: 2 PID: 17409 at kernel/workqueue.c:3968
destroy_workqueue+0x172/0x550()
Modules linked in:
CPU: 2 PID: 17409 Comm: syz-executor Not tainted 4.5.0-rc1+ #283
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff88003665f8a0 ffffffff8299a06d 0000000000000000
 ffff88003599c740 ffffffff8643f0c0 ffff88003665f8e0 ffffffff8134fcf9
 ffffffff8139d4c2 ffffffff8643f0c0 0000000000000f80 ffff8800630c5ae8
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff8299a06d>] dump_stack+0x6f/0xa2 lib/dump_stack.c:50
 [<ffffffff8134fcf9>] warn_slowpath_common+0xd9/0x140 kernel/panic.c:482
 [<ffffffff8134ff29>] warn_slowpath_null+0x29/0x30 kernel/panic.c:515
 [<ffffffff8139d4c2>] destroy_workqueue+0x172/0x550 kernel/workqueue.c:3968
 [<ffffffff85a714a4>] hci_unregister_dev+0x264/0x700
net/bluetooth/hci_core.c:3162
 [<ffffffff84595ce6>] vhci_release+0x76/0xe0 drivers/bluetooth/hci_vhci.c:341
 [<ffffffff817b2376>] __fput+0x236/0x780 fs/file_table.c:208
 [<ffffffff817b2945>] ____fput+0x15/0x20 fs/file_table.c:244
 [<ffffffff813ad760>] task_work_run+0x170/0x210 kernel/task_work.c:115
 [<     inline     >] exit_task_work include/linux/task_work.h:21
 [<ffffffff81358da5>] do_exit+0x8b5/0x2c60 kernel/exit.c:748
 [<ffffffff8135b2c8>] do_group_exit+0x108/0x330 kernel/exit.c:878
 [<ffffffff8137e434>] get_signal+0x5e4/0x14f0 kernel/signal.c:2307
 [<ffffffff811a1db3>] do_signal+0x83/0x1c90 arch/x86/kernel/signal.c:712
 [<ffffffff81006685>] exit_to_usermode_loop+0x1a5/0x210
arch/x86/entry/common.c:247
 [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:282
 [<ffffffff810084ea>] syscall_return_slowpath+0x2ba/0x340
arch/x86/entry/common.c:344
 [<ffffffff863597a2>] int_ret_from_sys_call+0x25/0x9f
arch/x86/entry/entry_64.S:281
---[ end trace f627386faee7426f ]---

Unfortunately I cannot reproduce it in a controlled environment, but
I've hit it twice in different VMs. So maybe if you see something
obvious there. Is it possible that something is submitted into the
workqueue between it is drained and destroyed in hci_unregister_dev?

On commit 92e963f50fc74041b5e9e744c330dca48e04f08d (Jan 24).
