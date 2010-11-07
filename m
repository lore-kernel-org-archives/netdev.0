From: Marin Mitov <mitov@issp.bas.bg>
Subject: [BUG]: skge not working (as module) in 2.6.37-rc1
Date: Sun, 7 Nov 2010 23:45:52 +0200
Message-ID: <201011072345.52784.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@osdl.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

skge as in 2.6.36 (and before) is working.
As in 2.6.37-rc1 it is not:

kernel: BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
kernel: IP: [<ffffffffa0005d20>] skge_devinit+0x270/0x2a0 [skge]
kernel: PGD d8657067 PUD d8658067 PMD 0
kernel: Oops: 0002 [#1] PREEMPT SMP
kernel: last sysfs file: /sys/devices/platform/mga_warp.0/firmware/mga_warp.0/loading
kernel: CPU 1
kernel: Modules linked in: skge(+)
kernel:
kernel: Pid: 2005, comm: insmod Not tainted 2.6.37-rc1 #2 A8V/System Product Name
kernel: RIP: 0010:[<ffffffffa0005d20>]  [<ffffffffa0005d20>] skge_devinit+0x270/0x2a0 [skge]
kernel: RSP: 0018:ffff8800ce477cb8  EFLAGS: 00010292
kernel: RAX: 0000000000000000 RBX: ffff88011f2cc800 RCX: ffffffff815ab260
kernel: RDX: ffffffff814e82a8 RSI: 0000000000000046 RDI: ffffffff815ab154
kernel: RBP: ffff8800ce477cd8 R08: 00000000ffffffff R09: 0000000000000000
kernel: R10: 0000000000000000 R11: 0000000000000000 R12: ffff8800daa27480
kernel: R13: 0000000000000000 R14: ffff88011f2ccd80 R15: 0000000000000000
kernel: FS:  00007f2af73f3700(0000) GS:ffff8800dfd00000(0000) knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
kernel: CR2: 0000000000000010 CR3: 00000000d865a000 CR4: 00000000000006e0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
kernel: Process insmod (pid: 2005, threadinfo ffff8800ce476000, task ffff880109875370)
kernel: Stack:
kernel:  ffff88011fe5f800 0000000000000000 ffff8800daa27480 ffff8800daa274e8
kernel:  ffff8800ce477d28 ffffffffa0006f2d ffff8800ce477d08 ffffffff8119555a
kernel:  ffff8800ce477d38 ffff88011fe5f888 ffff88011fe5f800 ffffffffa0008120
kernel: Call Trace:
kernel:  [<ffffffffa0006f2d>] skge_probe+0x27c/0x4a7 [skge]
kernel:  [<ffffffff8119555a>] ? kobject_get+0x1a/0x30
kernel:  [<ffffffff811aa812>] local_pci_probe+0x12/0x20
kernel:  [<ffffffff811aaae0>] pci_device_probe+0x80/0xb0
kernel:  [<ffffffff812337fa>] ? driver_sysfs_add+0x7a/0xb0
kernel:  [<ffffffff81233931>] driver_probe_device+0x81/0x1a0
kernel:  [<ffffffff81233ae3>] __driver_attach+0x93/0xa0
kernel:  [<ffffffff81233a50>] ? __driver_attach+0x0/0xa0
kernel:  [<ffffffff8123301c>] bus_for_each_dev+0x5c/0x90
kernel:  [<ffffffff81233779>] driver_attach+0x19/0x20
kernel:  [<ffffffff81232908>] bus_add_driver+0x198/0x250
kernel:  [<ffffffffa000c000>] ? skge_init_module+0x0/0x3a [skge]
kernel:  [<ffffffff81233dd8>] driver_register+0x78/0x140
kernel:  [<ffffffffa000c000>] ? skge_init_module+0x0/0x3a [skge]
kernel:  [<ffffffff811aad91>] __pci_register_driver+0x51/0xd0
kernel:  [<ffffffff812d4840>] ? dmi_check_system+0x20/0x50
kernel:  [<ffffffffa000c038>] skge_init_module+0x38/0x3a [skge]
kernel:  [<ffffffff810001de>] do_one_initcall+0x3e/0x170
kernel:  [<ffffffff81066192>] sys_init_module+0xb2/0x200
kernel:  [<ffffffff810024ab>] system_call_fastpath+0x16/0x1b
kernel: Code: 39 e1 48 89 df e8 81 a7 33 e1 ba 15 0f 00 00 48 c7 c6 08 7c 00 a0 48 c7 c7 48 73 00 a0 31 c0 e8 c1 aa 39 e1 48 8b 83 00 03 00 00 <f0> 80 48 10 01 ba 17 0f 00 00 48 c7 c6 08 7c 00 a0 48 c7 c7 48
kernel: RIP  [<ffffffffa0005d20>] skge_devinit+0x270/0x2a0 [skge]
kernel:  RSP <ffff8800ce477cb8>
kernel: CR2: 0000000000000010
kernel: ---[ end trace ef29176d9e5b71a4 ]---

Reverting the changes in skge.c (2.6.36 -> 2.6.37-rc1) does not help.
Debugging with many printk embedded in skge_devinit() found the problem is in
netif_stop_queue(dev). Removing the statement (see the patch) helps - skge is working.

But I am not expert in the networking, so I am not sure I have solved the real problem.
May be some changes in the core networking are the real cause of the problem.

And by the way, why one should stop a queue that is not yet (at least explicitly) started? :-)

Best regards.

Marin Mitov

Signed-off-by: Marin Mitov <mitov@issp.bas.bg>

===========================================================
--- a/drivers/net/skge.c	2010-11-07 10:55:22.000000000 +0200
+++ b/drivers/net/skge.c	2010-11-07 20:55:43.000000000 +0200
@@ -3858,7 +3858,6 @@ static struct net_device *skge_devinit(s
 
 	/* device is off until link detection */
 	netif_carrier_off(dev);
-	netif_stop_queue(dev);
 
 	return dev;
 }
