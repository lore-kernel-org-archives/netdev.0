From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: hitting lockdep warning as of too early VF probe with 3.9-rc1
Date: Tue, 5 Mar 2013 17:21:32 +0200
Message-ID: <51360D7C.3060209@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	"Jack Morgenstein" <jackm@dev.mellanox.co.il>
To: Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	"Roland Dreier" <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:53063 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755624Ab3CEPVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 10:21:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ming, Greg, Roland, Dave, all..

With 3.9-rc1, we are hitting the below lockdep with probing of virtual 
functions over the mlx4 driver, where it seems that the probing of the 
VF starts before the PF initialization is done.

Yan Burman from our team bisected that to be introduced by commit 
190888ac01d059e38ffe77a2291d44cafa9016fb
"driver core: fix possible missing of device probe".

Basically what happens is that the VF probe fails, and once the PF 
probing/initialization is done, the VF
is probed again and this time it succeeds.

Anything here which people see to be possibly wrong with the mlx4_core 
(drivers/net/ethernet/mellanox/mlx4) driver interaction with the PCI 
subsystem?

Or.


mlx4_core: Initializing 0000:04:00.0
mlx4_core 0000:04:00.0: Enabling SR-IOV with 1 VFs
pci 0000:04:00.1: [15b3:1004] type 00 class 0x028000

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
mlx4_core: Initializing 0000:04:00.1
mlx4_core 0000:04:00.1: enabling device (0000 -> 0002)
mlx4_core 0000:04:00.1: Detected virtual function - running in slave mode
mlx4_core 0000:04:00.1: Sending reset
mlx4_core 0000:04:00.1: Got slave FLRed from Communication channel (ret:0x1)
mlx4_core 0000:04:00.1: slave is currently in themiddle of FLR. 
retrying...(try num:1)
mlx4_core 0000:04:00.1: Communication channel is not idle.my toggle is 1 
(cmd:0x0)
mlx4_core 0000:04:00.1: slave is currently in themiddle of FLR. 
retrying...(try num:2)
[... repeated the same ...]
mlx4_core 0000:04:00.1: slave is currently in themiddle of FLR. 
retrying...(try num:10)
mlx4_core 0000:04:00.1: Communication channel is not idle.my toggle is 1 
(cmd:0x0)
mlx4_core 0000:04:00.1: slave driver version is not supported by the master
mlx4_core 0000:04:00.1: Communication channel is not idle.my toggle is 1 
(cmd:0x0)
mlx4_core 0000:04:00.1: Failed to initialize slave
mlx4_core: probe of 0000:04:00.1 failed with error -5
mlx4_core 0000:04:00.0: Running in master mode
mlx4_core 0000:04:00.0: FW version 2.11.500 (cmd intf rev 3), max 
commands 16
mlx4_core 0000:04:00.0: Catastrophic error buffer at 0x1f020, size 0x10, 
BAR 0
mlx4_core 0000:04:00.0: Communication vector bar:2 offset:0x800
[... probing of PF continues ...]
mlx4_core 0000:04:00.0: Started init_resource_tracker: 80 slaves
mlx4_core 0000:04:00.0: irq 83 for MSI/MSI-X
mlx4_core 0000:04:00.0: irq 84 for MSI/MSI-X
mlx4_core 0000:04:00.0: irq 85 for MSI/MSI-X
mlx4_core 0000:04:00.0: irq 86 for MSI/MSI-X
mlx4_core 0000:04:00.0: NOP command IRQ test passed
[... probing of PF ends ...]
[... probing of VF done again ...]
mlx4_core: Initializing 0000:04:00.1
mlx4_core 0000:04:00.1: enabling device (0000 -> 0002)
mlx4_core 0000:04:00.1: Detected virtual function - running in slave mode
mlx4_core 0000:04:00.1: Sending reset
mlx4_core 0000:04:00.0: Received reset from slave:1
mlx4_core 0000:04:00.1: Sending vhcr0
[... probing of VF succeeds ...]
mlx4_core 0000:04:00.1: NOP command IRQ test passed
