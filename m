From: Ralf Baechle <ralf@linux-mips.org>
Subject: Bpqether broken in 4.1
Date: Thu, 2 Jul 2015 20:38:36 +0200
Message-ID: <20150702183836.GA20390@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Whitehouse <swhiteho@redhat.com>,
	Richard Stearn <richard@rns-stearn.demon.co.uk>,
	f6bvp <f6bvp@free.fr>
To: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-hams-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:41349 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S27012793AbbGBSin7YL1m (ORCPT <rfc822;netdev@vger.kernel.org>
        + 1 other); Thu, 2 Jul 2015 20:38:43 +0200
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric's Commit 1d5da757da860a6916adbf68b09e868062b4b3b8 (ax25: Stop using
magic neighbour cache operations.) breaks IP traffic over the AX.25 bpqether
driver.

Here's how to reproduce the issue if you don't have an AX.25 setup.  The
arp command is there to fudge things if you don't have a peer that would
answer ARP requests.

# modprobe bpqether
# ifconfig bpq0 hw ax25 abcdef-7 172.20.4.1/24
# arp -H ax25 -s 172.20.4.2 uvwxyz-9
# ping 172.20.4.2

Result in one "Dead loop on virtual device bpq0, fix it urgently!" message
per ping packet.  With the following little debug patch

diff --git a/net/core/dev.c b/net/core/dev.c
index aa82f9a..5fef868 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3011,6 +3011,7 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 recursion_alert:
 			net_crit_ratelimited("Dead loop on virtual device %s, fix it urgently!\n",
 					     dev->name);
+			WARN_ON(1);
 		}
 	}
 
I get the following backtrace:

[   33.149171] Dead loop on virtual device bpq0, fix it urgently!
[   33.149718] ------------[ cut here ]------------
[   33.149754] WARNING: CPU: 0 PID: 0 at net/core/dev.c:3014 __dev_queue_xmit+0x3f6/0x530()
[   33.149769] Modules linked in:
[   33.149789] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.1.0-00010-g21c6d95-dirty #18
[   33.149799] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.1-20150318_183358- 04/01/2014
[   33.149810]  0000000000000000 de52945c8e778a65 ffff88007fc039a8 ffffffff816d2165
[   33.149823]  0000000000000000 0000000000000000 ffff88007fc039e8 ffffffff810634aa
[   33.149833]  ffff88007fc039c8 0000000000000000 ffff880078f90000 ffff880078f90000
[   33.149844] Call Trace:
[   33.149885]  <IRQ>  [<ffffffff816d2165>] dump_stack+0x45/0x57
[   33.149927]  [<ffffffff810634aa>] warn_slowpath_common+0x8a/0xc0
[   33.149939]  [<ffffffff810635da>] warn_slowpath_null+0x1a/0x20
[   33.149949]  [<ffffffff815c7c06>] __dev_queue_xmit+0x3f6/0x530
[   33.149967]  [<ffffffff8108cbed>] ? ttwu_do_wakeup+0x1d/0xe0
[   33.149978]  [<ffffffff815c7d53>] dev_queue_xmit_sk+0x13/0x20
[   33.149994]  [<ffffffff816b9951>] ax25_queue_xmit+0x61/0x70
[   33.150005]  [<ffffffff816b9476>] ax25_ip_xmit+0xd6/0x2d0
[   33.150022]  [<ffffffff8108fb47>] ? wake_up_process+0x27/0x50
[   33.150050]  [<ffffffff814dda35>] bpq_xmit+0x1d5/0x200
[   33.150061]  [<ffffffff815c7694>] dev_hard_start_xmit+0x264/0x3e0
[   33.150073]  [<ffffffff815c7ccd>] __dev_queue_xmit+0x4bd/0x530
[   33.150083]  [<ffffffff815c7d53>] dev_queue_xmit_sk+0x13/0x20
[   33.150099]  [<ffffffff815d03c2>] neigh_connected_output+0xc2/0x110
[   33.150110]  [<ffffffff815d3483>] neigh_update+0x333/0x770
[   33.150117]  [<ffffffff8162d2a7>] arp_process.isra.15+0x2f7/0x690
[   33.150117]  [<ffffffff8162d736>] arp_rcv+0xe6/0x130
[   33.150117]  [<ffffffff815c5543>] __netif_receive_skb_core+0x693/0x830
[   33.150117]  [<ffffffff815c56f8>] __netif_receive_skb+0x18/0x60
[   33.150117]  [<ffffffff815c6532>] process_backlog+0xb2/0x150
[   33.150117]  [<ffffffff815c5cd2>] net_rx_action+0x212/0x340
[   33.150117]  [<ffffffff81067aeb>] __do_softirq+0x10b/0x2d0
[   33.150117]  [<ffffffff81067f15>] irq_exit+0x145/0x150
[   33.150117]  [<ffffffff816da8a8>] do_IRQ+0x58/0xf0
[   33.150117]  [<ffffffff816d896e>] common_interrupt+0x6e/0x6e
[   33.150117]  <EOI>  [<ffffffff8104b236>] ? native_safe_halt+0x6/0x10
[   33.150117]  [<ffffffff810c4d43>] ? rcu_eqs_enter+0xa3/0xb0
[   33.150117]  [<ffffffff8100ddbe>] default_idle+0x1e/0xc0
[   33.150117]  [<ffffffff8100e81f>] arch_cpu_idle+0xf/0x20
[   33.150117]  [<ffffffff810a6f57>] cpu_startup_entry+0x377/0x3f0
[   33.150117]  [<ffffffff816c989c>] rest_init+0x7c/0x80
[   33.150117]  [<ffffffff81d32fe4>] start_kernel+0x484/0x4a5
[   33.150117]  [<ffffffff81d32120>] ? early_idt_handler_array+0x120/0x120
[   33.150117]  [<ffffffff81d32315>] x86_64_start_reservations+0x2a/0x2c
[   33.150117]  [<ffffffff81d3245c>] x86_64_start_kernel+0x145/0x168
[   33.150117] ---[ end trace ff4df9d904cced48 ]---

  Ralf
