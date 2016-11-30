From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Regression: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Wed, 30 Nov 2016 15:08:39 +0100
Message-ID: <20161130150839.5203ece0@redhat.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40724 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753639AbcK3OIn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 09:08:43 -0500
In-Reply-To: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 25 Nov 2016 07:46:20 -0800 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>

Ended up-in net-next as:

 commit 40931b85113dad7881d49e8759e5ad41d30a5e6c
 Author: Eric Dumazet <edumazet@google.com>
 Date:   Fri Nov 25 07:46:20 2016 -0800

    mlx4: give precise rx/tx bytes/packets counters
    
    mlx4 stats are chaotic because a deferred work queue is responsible
    to update them every 250 ms.

Likely after this patch I get this crash (below), when rebooting my machine.
Looks like a device removal order thing.
Tested with net-next at commit 93ba22225504.   

[...]
[ 1967.248453] mlx5_core 0000:02:00.1: Shutdown was called
[ 1967.854556] mlx5_core 0000:02:00.0: Shutdown was called
[ 1968.443015] e1000e: EEE TX LPI TIMER: 00000011
[ 1968.484676] sd 3:0:0:0: [sda] Synchronizing SCSI cache
[ 1968.528354] mlx4_core 0000:01:00.0: mlx4_shutdown was called
[ 1968.534054] mlx4_en: mlx4p1: Close port called
[ 1968.571156] mlx4_en 0000:01:00.0: removed PHC
[ 1968.575677] mlx4_en: mlx4p2: Close port called
[ 1969.506602] BUG: unable to handle kernel NULL pointer dereference at 0000000000000d08
[ 1969.514530] IP: [<ffffffffa0127ca4>] mlx4_en_fold_software_stats.part.1+0x34/0xb0 [mlx4_en]
[ 1969.522963] PGD 0 [ 1969.524803] 
[ 1969.526332] Oops: 0000 [#1] PREEMPT SMP
[ 1969.530201] Modules linked in: coretemp kvm_intel kvm irqbypass intel_cstate mxm_wmi i2c_i801 intel_rapl_perf i2c_smbus sg pcspkr i2c_core shpchp nfsd wmi video acpi_pad auth_rpcgss oid_registry nfs_acl lockd grace sunrpc ip_tables x_tables mlx4_en e1000e mlx5_core ptp serio_raw sd_mod mlx4_core pps_core devlink hid_generic
[ 1969.559616] CPU: 3 PID: 3104 Comm: kworker/3:1 Not tainted 4.9.0-rc6-net-next3-01390-g93ba22225504 #12
[ 1969.568984] Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./Z97 Extreme4, BIOS P2.10 05/12/2015
[ 1969.578877] Workqueue: events linkwatch_event
[ 1969.583285] task: ffff8803f42a0000 task.stack: ffff88040b2d0000
[ 1969.589238] RIP: 0010:[<ffffffffa0127ca4>]  [<ffffffffa0127ca4>] mlx4_en_fold_software_stats.part.1+0x34/0xb0 [mlx4_en]
[ 1969.600102] RSP: 0018:ffff88040b2d3bd8  EFLAGS: 00010282
[ 1969.605442] RAX: ffff8803f432efc8 RBX: ffff8803f4320000 RCX: 0000000000000000
[ 1969.612604] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8803f4320000
[ 1969.619772] RBP: ffff88040b2d3bd8 R08: 000000000000000c R09: ffff8803f432f000
[ 1969.626938] R10: 0000000000000000 R11: ffff88040d64ac00 R12: ffff8803e5aff8dc
[ 1969.634104] R13: ffff8803f4320a28 R14: ffff8803e5aff800 R15: 0000000000000000
[ 1969.641273] FS:  0000000000000000(0000) GS:ffff88041fac0000(0000) knlGS:0000000000000000
[ 1969.649422] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1969.655197] CR2: 0000000000000d08 CR3: 0000000001c07000 CR4: 00000000001406e0
[ 1969.662366] Stack:
[ 1969.664412]  ffff88040b2d3be8 ffffffffa0127f8e ffff88040b2d3c10 ffffffffa012a23b
[ 1969.671948]  ffff8803e5aff8dc ffff8803f4320000 ffff8803f4320000 ffff88040b2d3c30
[ 1969.679478]  ffffffff8160ae29 ffff8803e5aff8d8 ffff8804088ff300 ffff88040b2d3c58
[ 1969.687001] Call Trace:
[ 1969.689484]  [<ffffffffa0127f8e>] mlx4_en_fold_software_stats+0x1e/0x20 [mlx4_en]
[ 1969.697026]  [<ffffffffa012a23b>] mlx4_en_get_stats64+0x2b/0x50 [mlx4_en]
[ 1969.703844]  [<ffffffff8160ae29>] dev_get_stats+0x39/0xa0
[ 1969.709274]  [<ffffffff81622470>] rtnl_fill_stats+0x40/0x130
[ 1969.714968]  [<ffffffff8162631b>] rtnl_fill_ifinfo+0x55b/0x1010
[ 1969.720921]  [<ffffffff816285d3>] rtmsg_ifinfo_build_skb+0x73/0xd0
[ 1969.727136]  [<ffffffff81628646>] rtmsg_ifinfo.part.25+0x16/0x50
[ 1969.733176]  [<ffffffff81628698>] rtmsg_ifinfo+0x18/0x20
[ 1969.738522]  [<ffffffff8160e947>] netdev_state_change+0x47/0x50
[ 1969.744478]  [<ffffffff81629018>] linkwatch_do_dev+0x38/0x50
[ 1969.750170]  [<ffffffff81629257>] __linkwatch_run_queue+0xe7/0x160
[ 1969.756385]  [<ffffffff816292f5>] linkwatch_event+0x25/0x30
[ 1969.761991]  [<ffffffff8107b3cb>] process_one_work+0x15b/0x460
[ 1969.767857]  [<ffffffff8107b71e>] worker_thread+0x4e/0x480
[ 1969.773378]  [<ffffffff8107b6d0>] ? process_one_work+0x460/0x460
[ 1969.779420]  [<ffffffff8107b6d0>] ? process_one_work+0x460/0x460
[ 1969.785460]  [<ffffffff810811ea>] kthread+0xca/0xe0
[ 1969.790372]  [<ffffffff81081120>] ? kthread_worker_fn+0x120/0x120
[ 1969.796495]  [<ffffffff817302d2>] ret_from_fork+0x22/0x30
[ 1969.801924] Code: 00 00 55 48 89 e5 85 d2 0f 84 90 00 00 00 83 ea 01 31 c9 31 f6 48 8d 87 c0 ef 00 00 4c 8d 8c d7 c8 ef 00 00 48 8b 10 48 83 c0 08 <4c> 8b 82 08 0d 00 00 48 8b 92 00 0d 00 00 4c 01 c6 48 01 d1 4c 
[ 1969.821969] RIP  [<ffffffffa0127ca4>] mlx4_en_fold_software_stats.part.1+0x34/0xb0 [mlx4_en]
[ 1969.830486]  RSP <ffff88040b2d3bd8>
[ 1969.834002] CR2: 0000000000000d08
[ 1969.837440] ---[ end trace 80b9fbc1e7baed9b ]---
[ 1969.842102] Kernel panic - not syncing: Fatal exception in interrupt
[ 1969.848520] Kernel Offset: disabled
[ 1969.852050] ---[ end Kernel panic - not syncing: Fatal exception in interrupt
(END)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
