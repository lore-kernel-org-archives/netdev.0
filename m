From: Ingo Molnar <mingo@elte.hu>
Subject: [crash, bisected] net, sky2: BUG: unable to handle kernel NULL
	pointer dereference, pci_vpd_truncate()
Date: Mon, 6 Apr 2009 11:03:03 +0200
Message-ID: <20090406090303.GA12525@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:45675 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042AbZDFJDX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2009 05:03:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Not sure whether this has been reported before, but one of the -tip 
testboxes started showing the boot crash attached below. Reproduces 
with latest -git.

I have bisected it to:

| installing & booting kernel ... => good. (114 seconds)
| 3834507d0c5480a0f05486c2fb57ed18fd179a83 is first bad commit
| commit 3834507d0c5480a0f05486c2fb57ed18fd179a83
| Author: Stephen Hemminger <shemminger@vyatta.com>
| Date:   Tue Feb 3 11:27:30 2009 +0000
|
|     sky2: set VPD size
|    
|     Read configuration register during probe and use it to size the
|     available VPD. Move existing code using same register slightly
|     earlier in probe handling.

[ I'm testing the straight revert currently. Can send more info if 
  needed. ]

	Ingo

[   35.298806] initcall bnx2x_init+0x0/0x60 returned 0 after 129 usecs
[   35.305155] calling  skge_init_module+0x0/0x60 @ 1
[   35.310087] initcall skge_init_module+0x0/0x60 returned 0 after 77 usecs
[   35.316873] calling  sky2_init_module+0x0/0x60 @ 1
[   35.321741] sky2 driver version 1.22
[   35.325465] sky2 0000:02:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
[   35.332489] sky2 0000:02:00.0: setting latency timer to 64
[   35.338137] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
[   35.342329] IP: [<ffffffff8060107b>] pci_vpd_truncate+0x2b/0x40
[   35.342329] PGD 0 
[   35.342329] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
[   35.342329] last sysfs file: 
[   35.342329] CPU 0 
[   35.342329] Pid: 9, comm: work_on_cpu/0 Not tainted 2.6.29-tip-09528-g243ae82-dirty #3383 System Product Name
[   35.342329] RIP: 0010:[<ffffffff8060107b>]  [<ffffffff8060107b>] pci_vpd_truncate+0x2b/0x40
[   35.342329] RSP: 0018:ffff88007fbb3d20  EFLAGS: 00010206
[   35.342329] RAX: 0000000000000000 RBX: ffff88007fb59a60 RCX: 000000000000000a
[   35.342329] RDX: ffff88007fb88000 RSI: 0000000000000400 RDI: ffff88007e58e000
[   35.342329] RBP: ffff88007fbb3d20 R08: 0000000000000000 R09: 0000000000000309
[   35.342329] R10: ffff88007fbaa7a0 R11: 0000000000000002 R12: ffff88007e58e080
[   35.342329] R13: 0000000000000000 R14: ffff88007e58e000 R15: ffffffff802920c0
[   35.342329] FS:  0000000000000000(0000) GS:ffff880006200000(0000) knlGS:0000000000000000
[   35.431275] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
[   35.431275] CR2: 0000000000000018 CR3: 0000000000201000 CR4: 00000000000026a0
[   35.431275] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   35.431275] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   35.431275] Process work_on_cpu/0 (pid: 9, threadinfo ffff88007fbb2000, task ffff88007fbaa000)
[   35.431275] Stack:
[   35.431275]  ffff88007fbb3e20 ffffffff81013047 ffff88007fbaa000 0000000000000000
[   35.431275]  000000017fbaa768 0000000000000000 ffff880000000001 ffffffff80240700
[   35.431275]  ffff88007fbaa038 0000000000000038 ffff88007fbaa7a0 0000000000000038
[   35.431275] Call Trace:
[   35.431275]  [<ffffffff81013047>] sky2_probe+0x1d7/0xc10
[   35.431275]  [<ffffffff80240700>] ? native_sched_clock+0x20/0x80
[   35.431275]  [<ffffffff802a58e1>] ? __lock_acquire+0x201/0xa10
[   35.431275]  [<ffffffff802405b9>] ? sched_clock+0x9/0x10
[   35.431275]  [<ffffffff802920c0>] ? do_work_for_cpu+0x0/0x20
[   35.431275]  [<ffffffff80607b02>] local_pci_probe+0x12/0x20
[   35.431275]  [<ffffffff802920d3>] do_work_for_cpu+0x13/0x20
[   35.431275]  [<ffffffff8029323d>] worker_thread+0x24d/0x360
[   35.431275]  [<ffffffff802931c0>] ? worker_thread+0x1d0/0x360
[   35.431275]  [<ffffffff80296a50>] ? autoremove_wake_function+0x0/0x40
[   35.431275]  [<ffffffff80292ff0>] ? worker_thread+0x0/0x360
[   35.431275]  [<ffffffff8029660d>] kthread+0x4d/0x80
[   35.431275]  [<ffffffff8023a10a>] child_rip+0xa/0x20
[   35.431275]  [<ffffffff80239a90>] ? restore_args+0x0/0x30
[   35.431275]  [<ffffffff802965c0>] ? kthread+0x0/0x80
[   35.431275]  [<ffffffff8023a100>] ? child_rip+0x0/0x20
[   35.431275] Code: 55 48 8b 97 e0 07 00 00 48 89 e5 48 85 d2 75 07 c9 b8 ea ff ff ff c3 8b 02 48 39 f0 72 f2 89 32 48 8b 87 e0 07 00 00 48 8b 40 10 <48> 89 70 18 c9 31 c0 c3 66 66 66 90 66 66 90 66 66 90 66 66 90 
[   35.431275] RIP  [<ffffffff8060107b>] pci_vpd_truncate+0x2b/0x40
[   35.431275]  RSP <ffff88007fbb3d20>
