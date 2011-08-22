From: Josh Boyer <jwboyer@redhat.com>
Subject: mlx4 throws DMA sync error with CONFIG_DMA_API_DEBUG set
Date: Mon, 22 Aug 2011 08:22:35 -0400
Message-ID: <20110822122234.GF2270@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Roland Dreier <roland@purestorage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751760Ab1HVMWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Aug 2011 08:22:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The Fedora kernels run with DMA debugging enabled, and we've seen[1] the
mlx4 driver throw a backtrace for trying to sync DMA memory that
lib/dma-debug.c doesn't think it allocated.  It seems to stem from
mlx4_write_mtt_chunk calling a sync with &dev->pdev->dev as the device.
I'm not sure whether that is "illegal" or if it's just confusing enough
to the debug code that it throws an incorrect error.

Backtrace from 3.0.1 below, though I believe the code in question is still
basically the same in mainline.

josh

[1] https://bugzilla.redhat.com/show_bug.cgi?id=732279

[   30.626164] ------------[ cut here ]------------
[   30.631058] WARNING: at lib/dma-debug.c:911 check_sync+0xca/0x46c()
[   30.637589] Hardware name: X8DTH-i/6/iF/6F
[   30.641954] mlx4_core 0000:86:00.0: DMA-API: device driver tries to sync DMA
memory it has not allocated [device address=0x00000000fe181000] [size=4096
bytes]
[   30.656829] Modules linked in: ses enclosure ghes serio_raw hed i2c_i801
joydev i2c_core mpt2sas iTCO_wdt i7core_edac iTCO_vendor_support
scsi_transport_sas ioatdma raid_class edac_core mlx4_core(+) ib_ipoib rdma_ucm
rdma_cm iw_cm ib_addr ib_ucm ib_cm ib_sa ib_uverbs ib_umad ib_mad ib_core igb
dca ipmi_devintf ipmi_si ipmi_msghandler
[   30.689819] Pid: 846, comm: work_for_cpu Not tainted 3.0.1-5.fc16.x86_64 #1
[   30.697049] Call Trace:
[   30.699768]  [<ffffffff81058ebc>] warn_slowpath_common+0x83/0x9b
[   30.706044]  [<ffffffff81058f77>] warn_slowpath_fmt+0x46/0x48
[   30.712061]  [<ffffffff81253b41>] check_sync+0xca/0x46c
[   30.717557]  [<ffffffff8108aefc>] ? mark_held_locks+0x4b/0x6d
[   30.723576]  [<ffffffff8100e9fd>] ? paravirt_read_tsc+0x9/0xd
[   30.729589]  [<ffffffff8100eec7>] ? native_sched_clock+0x34/0x36
[   30.735862]  [<ffffffff812541d8>] debug_dma_sync_single_for_cpu+0x42/0x44
[   30.742920]  [<ffffffff814dbd6d>] ? __mutex_unlock_slowpath+0x112/0x122
[   30.749796]  [<ffffffff8108b029>] ? trace_hardirqs_on_caller+0x10b/0x12f
[   30.756765]  [<ffffffff814dbd75>] ? __mutex_unlock_slowpath+0x11a/0x122
[   30.763645]  [<ffffffff814dbd8b>] ? mutex_unlock+0xe/0x10
[   30.769319]  [<ffffffffa00da0b8>]
dma_sync_single_for_cpu.constprop.11+0x5d/0x66 [mlx4_core]
[   30.778243]  [<ffffffffa00da181>] mlx4_write_mtt+0xc0/0x133 [mlx4_core]
[   30.785135]  [<ffffffffa00d360d>] mlx4_create_eq+0x305/0x45c [mlx4_core]
[   30.792106]  [<ffffffffa00d3a26>] ? mlx4_init_eq_table+0x146/0x4ac
[mlx4_core]
[   30.799844]  [<ffffffff8112a0da>] ? __kmalloc+0xfa/0x10c
[   30.805439]  [<ffffffffa00d3a6f>] mlx4_init_eq_table+0x18f/0x4ac [mlx4_core]
[   30.812755]  [<ffffffffa00dd192>] mlx4_setup_hca+0x11a/0x410 [mlx4_core]
[   30.819729]  [<ffffffffa00d796c>] ? kzalloc.constprop.3+0x13/0x15
[mlx4_core]
[   30.827128]  [<ffffffffa00d8118>] __mlx4_init_one+0x7aa/0x7bb [mlx4_core]
[   30.834189]  [<ffffffff8106f9d8>] ? move_linked_works+0x6e/0x6e
[   30.840374]  [<ffffffffa00dd4c5>] mlx4_init_one+0x3d/0x42 [mlx4_core]
[   30.847083]  [<ffffffff8125dca6>] local_pci_probe+0x44/0x75
[   30.852921]  [<ffffffff8106f9ee>] do_work_for_cpu+0x16/0x28
[   30.858765]  [<ffffffff81075e5d>] kthread+0xa8/0xb0
[   30.863914]  [<ffffffff814e50a4>] kernel_thread_helper+0x4/0x10
[   30.870096]  [<ffffffff814dd754>] ? retint_restore_args+0x13/0x13
[   30.876459]  [<ffffffff81075db5>] ? __init_kthread_worker+0x5a/0x5a
[   30.882994]  [<ffffffff814e50a0>] ? gs_change+0x13/0x13
[   30.888487] ---[ end trace ede39044efbe156f ]---
