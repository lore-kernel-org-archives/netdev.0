From: Haggai Eran <haggaie@mellanox.com>
Subject: WARNING: at net/core/skbuff.c:573
Date: Tue, 30 Oct 2012 09:47:30 +0200
Message-ID: <508F8612.2040301@mellanox.com>
References: <B855DA7245737D4B83EDD9C0B7698E652B7D29DA@MTRDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:51984 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755796Ab2J3HsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 03:48:18 -0400
In-Reply-To: <B855DA7245737D4B83EDD9C0B7698E652B7D29DA@MTRDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Running kernel v3.7-rc2 I'm getting these warnings at
skb_release_head_state. It is called from netconsole, due to printk
from mlx4_core's interrupt handler. The warning is due to the function 
being run in interrupt context. However, according to the documentation,
netconsole is supposed to be fine running from within interrupts.

I'm not sure I can reproduce it reliably though.

Haggai

[73550.981930] ------------[ cut here ]------------
[73550.981933] WARNING: at net/core/skbuff.c:573 skb_release_head_state+0x10f/0x120()
[73550.981933] Hardware name: PowerEdge R710
[73550.981961] Modules linked in: rdma_ucm rdma_cm iw_cm ib_addr ib_ipoib ib_cm ib_uverbs ib_umad mlx4_ib ib_sa ib_mad ib_core mlx4_en mlx4_core mmu_trace(O) mst_pciconf(O) mst_pci(O) netconsole configfs nfsv3 nfs_acl nfsv4 auth_rpcgss nfs fscache lockd autofs4 sunrpc ipv6 dm_mirror dm_region_hash dm_log dm_mod uinput iTCO_wdt iTCO_vendor_support dcdbas sg ses enclosure coretemp hwmon kvm_intel kvm crc32c_intel ghash_clmulni_intel serio_raw pcspkr lpc_ich mfd_core bnx2 ext3 jbd mbcache sr_mod cdrom sd_mod crc_t10dif aesni_intel ablk_helper cryptd lrw aes_x86_64 xts gf128mul pata_acpi ata_generic ata_piix megaraid_sas [last unloaded: mlx4_core]
[73550.981962] Pid: 9167, comm: odp Tainted: G        W  O 3.7.0-rc2-odp+ #8
[73550.981963] Call Trace:
[73550.981965]  <IRQ>  [<ffffffff8104619f>] warn_slowpath_common+0x7f/0xc0
[73550.981967]  [<ffffffff810461fa>] warn_slowpath_null+0x1a/0x20
[73550.981969]  [<ffffffff8147e9ff>] skb_release_head_state+0x10f/0x120
[73550.981971]  [<ffffffff8147e766>] __kfree_skb+0x16/0xa0
[73550.981973]  [<ffffffff8147eab1>] consume_skb+0x31/0xe0
[73550.981978]  [<ffffffffa00f7369>] bnx2_poll_work+0x2d9/0x13f0 [bnx2]
[73550.981980]  [<ffffffff8157ccc9>] ? _raw_spin_lock_irqsave+0x29/0x70
[73550.981982]  [<ffffffff8157d577>] ? _raw_spin_unlock_irqrestore+0x77/0x80
[73550.981984]  [<ffffffff8157ccc9>] ? _raw_spin_lock_irqsave+0x29/0x70
[73550.981986]  [<ffffffff8157d577>] ? _raw_spin_unlock_irqrestore+0x77/0x80
[73550.981988]  [<ffffffff810abc89>] ? trace_hardirqs_off_caller+0x29/0xc0
[73550.981990]  [<ffffffff810abd2d>] ? trace_hardirqs_off+0xd/0x10
[73550.981995]  [<ffffffffa00f84c3>] bnx2_poll_msix+0x43/0xd0 [bnx2]
[73550.981996]  [<ffffffff8157d6cc>] ? _raw_spin_trylock+0x6c/0x80
[73550.981998]  [<ffffffff814a8dce>] netpoll_poll_dev+0x14e/0x7a0
[73550.982001]  [<ffffffff814a972c>] netpoll_send_skb_on_dev+0x30c/0x400
[73550.982003]  [<ffffffff814a9b13>] netpoll_send_udp+0x263/0x2b0
[73550.982006]  [<ffffffffa00812f3>] write_msg+0xc3/0x120 [netconsole]
[73550.982008]  [<ffffffff810483f3>] call_console_drivers.clone.3+0xa3/0x1c0
[73550.982010]  [<ffffffff810487c8>] console_unlock+0x2b8/0x450
[73550.982012]  [<ffffffff81048d7e>] vprintk_emit+0x1de/0x5b0
[73550.982014]  [<ffffffff81579aed>] printk+0x4d/0x4f
[73550.982015]  [<ffffffff8129e41c>] ? ___ratelimit+0xac/0x150
[73550.982020]  [<ffffffffa03f5829>] mlx4_eq_int+0x779/0xc50 [mlx4_core]
[73550.982025]  [<ffffffffa000152f>] ? megasas_isr+0x5f/0x200 [megaraid_sas]
[73550.982027]  [<ffffffff8157ccc9>] ? _raw_spin_lock_irqsave+0x29/0x70
[73550.982029]  [<ffffffff813636c1>] ? add_interrupt_randomness+0x41/0x190
[73550.982034]  [<ffffffffa03f5d14>] mlx4_msi_x_interrupt+0x14/0x20 [mlx4_core]
[73550.982036]  [<ffffffff810e3fd5>] handle_irq_event_percpu+0x95/0x390
[73550.982039]  [<ffffffff8139be30>] ? scsi_get_command+0xc0/0xc0
[73550.982040]  [<ffffffff810e4318>] handle_irq_event+0x48/0x70
[73550.982043]  [<ffffffff810e796d>] handle_edge_irq+0x6d/0x130
[73550.982044]  [<ffffffff8100470c>] handle_irq+0x5c/0x150
[73550.982046]  [<ffffffff8104fdcb>] ? irq_enter+0x1b/0x90
[73550.982048]  [<ffffffff8158855d>] do_IRQ+0x5d/0xe0
[73550.982050]  [<ffffffff8157d9b2>] common_interrupt+0x72/0x72
[73550.982052]  [<ffffffff8157da73>] ? retint_restore_args+0x13/0x13
[73550.982054]  [<ffffffff8157d540>] ? _raw_spin_unlock_irqrestore+0x40/0x80
[73550.982056]  [<ffffffff8157d545>] ? _raw_spin_unlock_irqrestore+0x45/0x80
[73550.982061]  [<ffffffffa00011d7>] megasas_queue_command+0x77/0x170 [megaraid_sas]
[73550.982063]  [<ffffffff8139bfdb>] scsi_dispatch_cmd+0xeb/0x380
[73550.982065]  [<ffffffff813a2f18>] scsi_request_fn+0x408/0x6f0
[73550.982067]  [<ffffffff8127158e>] __blk_run_queue+0x1e/0x20
[73550.982069]  [<ffffffff81273f30>] blk_run_queue+0x30/0x50
[73550.982071]  [<ffffffff813a23e2>] scsi_run_queue+0xd2/0x2a0
[73550.982073]  [<ffffffff810af0ad>] ? trace_hardirqs_on+0xd/0x10
[73550.982075]  [<ffffffff813a3452>] scsi_next_command+0x42/0x60
[73550.982077]  [<ffffffff813a41c6>] scsi_io_completion+0x2b6/0x670
[73550.982079]  [<ffffffff8139b2f9>] scsi_finish_command+0xc9/0x130
[73550.982081]  [<ffffffff813a46e7>] scsi_softirq_done+0x147/0x170
[73550.982083]  [<ffffffff8127e9ea>] blk_done_softirq+0x8a/0xa0
[73550.982086]  [<ffffffff81050810>] __do_softirq+0x110/0x3c0
[73550.982088]  [<ffffffff8139be30>] ? scsi_get_command+0xc0/0xc0
[73550.982090]  [<ffffffff81587e3c>] call_softirq+0x1c/0x30
[73550.982092]  [<ffffffff8100467d>] do_softirq+0xad/0xe0
[73550.982094]  [<ffffffff8104fc75>] irq_exit+0xe5/0x100
[73550.982095]  [<ffffffff81588566>] do_IRQ+0x66/0xe0
[73550.982097]  [<ffffffff8157d9b2>] common_interrupt+0x72/0x72
[73550.982100]  <EOI>  [<ffffffff8157d540>] ? _raw_spin_unlock_irqrestore+0x40/0x80
[73550.982102]  [<ffffffff8157d545>] ? _raw_spin_unlock_irqrestore+0x45/0x80
[73550.982106]  [<ffffffffa00011d7>] megasas_queue_command+0x77/0x170 [megaraid_sas]
[73550.982109]  [<ffffffff8139bfdb>] scsi_dispatch_cmd+0xeb/0x380
[73550.982111]  [<ffffffff813a2f18>] scsi_request_fn+0x408/0x6f0
[73550.982113]  [<ffffffff81293c5c>] ? cfq_insert_request+0x4c/0x630
[73550.982115]  [<ffffffff8127158e>] __blk_run_queue+0x1e/0x20
[73550.982117]  [<ffffffff81293f77>] cfq_insert_request+0x367/0x630
[73550.982118]  [<ffffffff81293c5c>] ? cfq_insert_request+0x4c/0x630
[73550.982121]  [<ffffffff81278db0>] ? blk_flush_plug_list+0x180/0x270
[73550.982123]  [<ffffffff812ad173>] ? debug_object_activate+0x83/0x190
[73550.982125]  [<ffffffff81270e88>] __elv_add_request+0x138/0x2b0
[73550.982127]  [<ffffffff81278de4>] blk_flush_plug_list+0x1b4/0x270
[73550.982129]  [<ffffffff8157c010>] schedule+0x50/0x70
[73550.982130]  [<ffffffff81579cce>] schedule_timeout+0x15e/0x2c0
[73550.982132]  [<ffffffff810581c0>] ? lock_timer_base+0x70/0x70
[73550.982135]  [<ffffffff8157be8b>] wait_for_common+0x12b/0x180
[73550.982136]  [<ffffffff81086c10>] ? try_to_wake_up+0x300/0x300
[73550.982138]  [<ffffffff8157bf93>] wait_for_completion_timeout+0x13/0x20
[73550.982143]  [<ffffffffa03f28f2>] __mlx4_cmd+0x2a2/0x5c0 [mlx4_core]
[73550.982149]  [<ffffffffa04021d6>] mlx4_SYNC_TPT+0x36/0x40 [mlx4_core]
[73550.982151]  [<ffffffff8157a80e>] ? mutex_unlock+0xe/0x10
[73550.982156]  [<ffffffffa0436e3d>] invalidation_handler+0x22d/0x3b0 [mlx4_ib]
[73550.982161]  [<ffffffffa0436c10>] ? mlx4_ib_qp_pfault_action+0x40/0x40 [mlx4_ib]
[73550.982166]  [<ffffffffa043702d>] mlx4_ib_invalidate_page+0x2d/0x30 [mlx4_ib]
[73550.982170]  [<ffffffffa025c764>] invalidate_page_trampoline+0x34/0x50 [ib_core]
[73550.982175]  [<ffffffffa025d7e4>] rbt_ib_umem_for_each_in_range+0xa4/0x150 [ib_core]
[73550.982179]  [<ffffffffa025c730>] ? invalidate_range_start_trampoline+0x60/0x60 [ib_core]
[73550.982183]  [<ffffffffa025cf33>] ib_umem_notifier_invalidate_page+0x63/0x80 [ib_core]
[73550.982185]  [<ffffffff8117ace5>] __mmu_notifier_invalidate_page+0xa5/0x1b0
[73550.982188]  [<ffffffff8117ac40>] ? mmu_notifier_unregister+0x1e0/0x1e0
[73550.982190]  [<ffffffff811660f8>] try_to_unmap_one+0x3f8/0x470
[73550.982192]  [<ffffffff81164ff1>] ? page_lock_anon_vma+0x151/0x2b0
[73550.982194]  [<ffffffff81164ea0>] ? page_get_anon_vma+0x1b0/0x1b0
[73550.982196]  [<ffffffff811668fc>] try_to_unmap_anon+0xbc/0x160
[73550.982198]  [<ffffffff81166a6b>] try_to_unmap+0x6b/0xa0
[73550.982201]  [<ffffffff811407ab>] shrink_page_list+0x3eb/0xa50
[73550.982203]  [<ffffffff8114210f>] shrink_inactive_list+0x17f/0x4c0
[73550.982205]  [<ffffffff811426ec>] ? shrink_active_list+0x29c/0x340
[73550.982207]  [<ffffffff81142c25>] shrink_lruvec+0x495/0x5b0
[73550.982209]  [<ffffffff812943dc>] ? cfq_dispatch_requests+0x19c/0xd20
[73550.982211]  [<ffffffff8157ccc9>] ? _raw_spin_lock_irqsave+0x29/0x70
[73550.982213]  [<ffffffff81142da6>] shrink_zone+0x66/0xc0
[73550.982215]  [<ffffffff8114451b>] do_try_to_free_pages+0xeb/0x630
[73550.982217]  [<ffffffff81144c0b>] try_to_free_mem_cgroup_pages+0xbb/0x200
[73550.982219]  [<ffffffff810aef10>] ? trace_hardirqs_on_caller+0x20/0x1b0
[73550.982221]  [<ffffffff8119069e>] mem_cgroup_reclaim+0x4e/0xe0
[73550.982223]  [<ffffffff8119101c>] __mem_cgroup_try_charge+0x4cc/0x9e0
[73550.982225]  [<ffffffff81194874>] ? swap_cgroup_record+0x34/0x60
[73550.982228]  [<ffffffff81191943>] __mem_cgroup_try_charge_swapin+0xa3/0xc0
[73550.982231]  [<ffffffff811919af>] mem_cgroup_try_charge_swapin+0x4f/0x60
[73550.982232]  [<ffffffff8115b5ec>] handle_pte_fault+0x30c/0x9d0
[73550.982234]  [<ffffffff8119410f>] ? mem_cgroup_count_vm_event+0x1f/0x190
[73550.982236]  [<ffffffff8115bf01>] handle_mm_fault+0x251/0x310
[73550.982238]  [<ffffffff81581943>] __do_page_fault+0x223/0x510
[73550.982240]  [<ffffffff810aef10>] ? trace_hardirqs_on_caller+0x20/0x1b0
[73550.982242]  [<ffffffff810af0ad>] ? trace_hardirqs_on+0xd/0x10
[73550.982244]  [<ffffffff8157d4e0>] ? _raw_spin_unlock_irq+0x30/0x50
[73550.982246]  [<ffffffff81080ee5>] ? finish_task_switch+0x85/0x120
[73550.982248]  [<ffffffff81080ea8>] ? finish_task_switch+0x48/0x120
[73550.982250]  [<ffffffff8157df06>] ? error_sti+0x5/0x6
[73550.982252]  [<ffffffff810abc89>] ? trace_hardirqs_off_caller+0x29/0xc0
[73550.982254]  [<ffffffff812a5ebd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[73550.982256]  [<ffffffff81581c3e>] do_page_fault+0xe/0x10
[73550.982258]  [<ffffffff8157dcb8>] page_fault+0x28/0x30
[73550.982259] ---[ end trace 12bb14f2b81db036 ]---
