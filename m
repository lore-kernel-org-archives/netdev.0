From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH for-3.9] pci: avoid work_on_cpu for nested SRIOV probes
Date: Thu, 11 Apr 2013 18:25:06 +0300
Message-ID: <20130411152505.GA22506@redhat.com>
References: <51360D7C.3060209@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62606 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936173Ab3DKPZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 11:25:27 -0400
Content-Disposition: inline
In-Reply-To: <51360D7C.3060209@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following lockdep report triggers since 3.9-rc1:

=============================================
[ INFO: possible recursive locking detected ]
3.9.0-rc1 #96 Not tainted
---------------------------------------------
kworker/0:1/734 is trying to acquire lock:
 ((&wfc.work)){+.+.+.}, at: [<ffffffff81066cb0>] flush_work+0x0/0x250

but task is already holding lock:
 ((&wfc.work)){+.+.+.}, at: [<ffffffff81064352>]
process_one_work+0x162/0x4c0

other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock((&wfc.work));
  lock((&wfc.work));

 *** DEADLOCK ***

 May be due to missing lock nesting notation

3 locks held by kworker/0:1/734:
 #0:  (events){.+.+.+}, at: [<ffffffff81064352>]
process_one_work+0x162/0x4c0
 #1:  ((&wfc.work)){+.+.+.}, at: [<ffffffff81064352>]
process_one_work+0x162/0x4c0
 #2:  (&__lockdep_no_validate__){......}, at: [<ffffffff812db225>]
device_attach+0x25/0xb0

stack backtrace:
Pid: 734, comm: kworker/0:1 Not tainted 3.9.0-rc1 #96
Call Trace:
 [<ffffffff810948ec>] validate_chain+0xdcc/0x11f0
 [<ffffffff81095150>] __lock_acquire+0x440/0xc70
 [<ffffffff81095150>] ? __lock_acquire+0x440/0xc70
 [<ffffffff810959da>] lock_acquire+0x5a/0x70
 [<ffffffff81066cb0>] ? wq_worker_waking_up+0x60/0x60
 [<ffffffff81066cf5>] flush_work+0x45/0x250
 [<ffffffff81066cb0>] ? wq_worker_waking_up+0x60/0x60
 [<ffffffff810922be>] ? mark_held_locks+0x9e/0x130
 [<ffffffff81066a96>] ? queue_work_on+0x46/0x90
 [<ffffffff810925dd>] ? trace_hardirqs_on_caller+0xfd/0x190
 [<ffffffff8109267d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff81066f74>] work_on_cpu+0x74/0x90
 [<ffffffff81063820>] ? keventd_up+0x20/0x20
 [<ffffffff8121fd30>] ? pci_pm_prepare+0x60/0x60
 [<ffffffff811f9293>] ? cpumask_next_and+0x23/0x40
 [<ffffffff81220a1a>] pci_device_probe+0xba/0x110
 [<ffffffff812dadca>] ? driver_sysfs_add+0x7a/0xb0
 [<ffffffff812daf1f>] driver_probe_device+0x8f/0x230
 [<ffffffff812db170>] ? __driver_attach+0xb0/0xb0
 [<ffffffff812db1bb>] __device_attach+0x4b/0x60
 [<ffffffff812d9314>] bus_for_each_drv+0x64/0x90
 [<ffffffff812db298>] device_attach+0x98/0xb0
 [<ffffffff81218474>] pci_bus_add_device+0x24/0x50
 [<ffffffff81232e80>] virtfn_add+0x240/0x3e0
 [<ffffffff8146ce3d>] ? _raw_spin_unlock_irqrestore+0x3d/0x80
 [<ffffffff812333be>] pci_enable_sriov+0x23e/0x500
 [<ffffffffa011fa1a>] __mlx4_init_one+0x5da/0xce0 [mlx4_core]
 [<ffffffffa012016d>] mlx4_init_one+0x2d/0x60 [mlx4_core]
 [<ffffffff8121fd79>] local_pci_probe+0x49/0x80
 [<ffffffff81063833>] work_for_cpu_fn+0x13/0x20
 [<ffffffff810643b8>] process_one_work+0x1c8/0x4c0
 [<ffffffff81064352>] ? process_one_work+0x162/0x4c0
 [<ffffffff81064cfb>] worker_thread+0x30b/0x430
 [<ffffffff810649f0>] ? manage_workers+0x340/0x340
 [<ffffffff8106cea6>] kthread+0xd6/0xe0
 [<ffffffff8106cdd0>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff8146daac>] ret_from_fork+0x7c/0xb0
 [<ffffffff8106cdd0>] ? __init_kthread_worker+0x70/0x70

The issue is that a driver, in it's probe function, calls
pci_sriov_enable so a PF device probe causes VF probe (AKA nested
probe).  Each probe in pci_device_probe which is (normally) run through
work_on_cpu (this is to get the right numa node for memory allocated by
the driver).  In turn work_on_cpu does this internally:

        schedule_work_on(cpu, &wfc.work);
        flush_work(&wfc.work);

So if you are running probe on CPU1, and cause another
probe on the same CPU, this will try to flush
workqueue from inside same workqueue which of course
deadlocks.

Nested probing might be tricky to get right generally.

But for pci_sriov_enable, the situation is actually very simple: all VFs
naturally have same affinity as the PF, and cpumask_any_and is actually
same as cpumask_first_and, so it always gives us the same CPU.
So let's just detect that, and run the probing for VFs locally without a
workqueue.

This is hardly elegant, but looks to me like an appropriate quick fix
for 3.9.

Tested-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
index 1fa1e48..6eeb5ec 100644
--- a/drivers/pci/pci-driver.c
+++ b/drivers/pci/pci-driver.c
@@ -286,8 +286,8 @@ static int pci_call_probe(struct pci_driver *drv, struct pci_dev *dev,
 		int cpu;
 
 		get_online_cpus();
 		cpu = cpumask_any_and(cpumask_of_node(node), cpu_online_mask);
-		if (cpu < nr_cpu_ids)
+		if (cpu != raw_smp_processor_id() && cpu < nr_cpu_ids)
 			error = work_on_cpu(cpu, local_pci_probe, &ddi);
 		else
 			error = local_pci_probe(&ddi);
