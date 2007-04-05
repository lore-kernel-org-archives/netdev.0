From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: Re: 2.6.21-rc5-mm4
Date: Wed, 4 Apr 2007 19:04:02 -0700
Message-ID: <20070404190402.609cbd65.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Antonino A. Daplas" <adaplas@pol.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38098 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932563AbXDECEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2007 22:04:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This looks like a locking bug in the ipv6 changes in davem's devel tree.
There are no relevant changes to drivers/net/sc92031.c in rc5-mm4.



Begin forwarded message:

Date: Thu, 05 Apr 2007 08:56:38 +0800
From: "Antonino A. Daplas" <adaplas@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org
Subject: Re: 2.6.21-rc5-mm4


On Mon, 2007-04-02 at 22:47 -0700, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.21-rc5/2.6.21-rc5-mm4/
> 
> - The oops in git-net.patch has been fixed, so that tree has been restored. 
>   It is huge.
> 
> - Added the device-mapper development tree to the -mm lineup (Alasdair
>   Kergon).  It is a quilt tree, living at
>   ftp://ftp.kernel.org/pub/linux/kernel/people/agk/patches/2.6/editing/.
> 
> - Added davidel's signalfd stuff.
> 
> 
> 

I see this tracing (from the lock-dependency validator?) for several -mm
versions.  This is from a Silan ethernet card (CONFIG_SC92031).

00:0b.0 Ethernet controller: Hangzhou Silan Microelectronics Co., Ltd.
Unknown device 2031 (rev 01)

Other than the tracing, I'm not having any problems.

Tony

======================================================
[ INFO: soft-safe -> soft-unsafe lock order detected ]
2.6.21-rc5-mm4-default #44
------------------------------------------------------
ip/3036 [HC0[0]:SC0[2]:HE1:SE0] is trying to acquire:
 (&priv->lock){--..}, at: [<d886ad22>] sc92031_set_multicast_list
+0x14/0x2d [sc92031]

and this task is already holding:
 (&dev->_xmit_lock){-...}, at: [<c02568b3>] dev_mc_upload+0x14/0x3a
which would create a new lock dependency:
 (&dev->_xmit_lock){-...} -> (&priv->lock){--..}

but this new dependency connects a soft-irq-safe lock:
 (&mc->mca_lock){-+..}
... which became soft-irq-safe at:
  [<c012f5b5>] __lock_acquire+0x3d7/0xb93
  [<c012fdd9>] lock_acquire+0x68/0x82
  [<c02aaf2a>] _spin_lock_bh+0x30/0x3d
  [<d8c53833>] mld_ifc_timer_expire+0x15b/0x21d [ipv6]
  [<c011cbd6>] run_timer_softirq+0xf1/0x14e
  [<c011a5a6>] __do_softirq+0x46/0x9c
  [<c011a629>] do_softirq+0x2d/0x46
  [<c011a9d5>] irq_exit+0x3b/0x6b
  [<c01057f0>] do_IRQ+0x5e/0x76
  [<c0103f16>] common_interrupt+0x2e/0x34
  [<c02ab3b9>] error_code+0x71/0x78
  [<ffffffff>] 0xffffffff

to a soft-irq-unsafe lock:
 (&priv->lock){--..}
... which became soft-irq-unsafe at:
...  [<c012f649>] __lock_acquire+0x46b/0xb93
  [<c012fdd9>] lock_acquire+0x68/0x82
  [<c02aaeed>] _spin_lock+0x2b/0x38
  [<d886b729>] sc92031_open+0xcc/0x16f [sc92031]
  [<c02549e7>] dev_open+0x33/0x6e
  [<c025337f>] dev_change_flags+0x57/0x10b
  [<c028b237>] devinet_ioctl+0x235/0x546
  [<c028b837>] inet_ioctl+0x89/0xaa
  [<c0249cd1>] sock_ioctl+0x1ac/0x1ca
  [<c0170a70>] do_ioctl+0x1c/0x53
  [<c0170c93>] vfs_ioctl+0x1ec/0x203
  [<c0170cf3>] sys_ioctl+0x49/0x62
  [<c0103ca8>] sysenter_past_esp+0x5d/0x99
  [<ffffffff>] 0xffffffff

other info that might help us debug this:

2 locks held by ip/3036:
 #0:  (rtnl_mutex){--..}, at: [<c02a9ea5>] mutex_lock+0x24/0x28
 #1:  (&dev->_xmit_lock){-...}, at: [<c02568b3>] dev_mc_upload+0x14/0x3a

the soft-irq-safe lock's dependencies:
-> (&mc->mca_lock){-+..} ops: 9 {
   initial-use  at:
                        [<c012f664>] __lock_acquire+0x486/0xb93
                        [<c012fdd9>] lock_acquire+0x68/0x82
                        [<c02aaf2a>] _spin_lock_bh+0x30/0x3d
                        [<d8c53983>] igmp6_group_added+0x1b/0x120 [ipv6]
                        [<d8c54175>] ipv6_dev_mc_inc+0x2f9/0x346 [ipv6]
                        [<d8c42f7f>] ipv6_add_dev+0x232/0x240 [ipv6]
                        [<d8c1430b>] ____versions+0x1e8b/0xfffff9c8
[x_tables]
                        [<d8c141d4>] ____versions+0x1d54/0xfffff9c8
[x_tables]
                        [<c01365eb>] sys_init_module+0x1252/0x138f
                        [<c0103ca8>] sysenter_past_esp+0x5d/0x99
                        [<ffffffff>] 0xffffffff
   in-softirq-W at:
                        [<c012f5b5>] __lock_acquire+0x3d7/0xb93
                        [<c012fdd9>] lock_acquire+0x68/0x82
                        [<c02aaf2a>] _spin_lock_bh+0x30/0x3d
                        [<d8c53833>] mld_ifc_timer_expire+0x15b/0x21d
[ipv6]
                        [<c011cbd6>] run_timer_softirq+0xf1/0x14e
                        [<c011a5a6>] __do_softirq+0x46/0x9c
                        [<c011a629>] do_softirq+0x2d/0x46
                        [<c011a9d5>] irq_exit+0x3b/0x6b
                        [<c01057f0>] do_IRQ+0x5e/0x76
                        [<c0103f16>] common_interrupt+0x2e/0x34
                        [<c02ab3b9>] error_code+0x71/0x78
                        [<ffffffff>] 0xffffffff
   hardirq-on-W at:
                        [<c012f61f>] __lock_acquire+0x441/0xb93
                        [<c012fdd9>] lock_acquire+0x68/0x82
                        [<c02aaf2a>] _spin_lock_bh+0x30/0x3d
                        [<d8c53983>] igmp6_group_added+0x1b/0x120 [ipv6]
                        [<d8c54175>] ipv6_dev_mc_inc+0x2f9/0x346 [ipv6]
                        [<d8c42f7f>] ipv6_add_dev+0x232/0x240 [ipv6]
                        [<d8c1430b>] ____versions+0x1e8b/0xfffff9c8
[x_tables]
                        [<d8c141d4>] ____versions+0x1d54/0xfffff9c8
[x_tables]
                        [<c01365eb>] sys_init_module+0x1252/0x138f
                        [<c0103ca8>] sysenter_past_esp+0x5d/0x99
                        [<ffffffff>] 0xffffffff
 }
 ... key      at: [<d8c75bbc>] __key.29988+0x0/0xfffe9535 [ipv6]
 -> (&dev->_xmit_lock){-...} ops: 18 {
    initial-use  at:
                          [<c012f664>] __lock_acquire+0x486/0xb93
                          [<c012fdd9>] lock_acquire+0x68/0x82
                          [<c02aaf2a>] _spin_lock_bh+0x30/0x3d
                          [<c02568b3>] dev_mc_upload+0x14/0x3a
                          [<c0253359>] dev_change_flags+0x31/0x10b
                          [<c028b237>] devinet_ioctl+0x235/0x546
                          [<c028b837>] inet_ioctl+0x89/0xaa
                          [<c0249cd1>] sock_ioctl+0x1ac/0x1ca
                          [<c0170a70>] do_ioctl+0x1c/0x53
                          [<c0170c93>] vfs_ioctl+0x1ec/0x203
                          [<c0170cf3>] sys_ioctl+0x49/0x62
                          [<c0103ca8>] sysenter_past_esp+0x5d/0x99
                          [<ffffffff>] 0xffffffff
    hardirq-on-W at:
                          [<c012f61f>] __lock_acquire+0x441/0xb93
                          [<c012fdd9>] lock_acquire+0x68/0x82
                          [<c02aaf2a>] _spin_lock_bh+0x30/0x3d
                          [<c02568b3>] dev_mc_upload+0x14/0x3a
                          [<c0253359>] dev_change_flags+0x31/0x10b
                          [<c028b237>] devinet_ioctl+0x235/0x546
                          [<c028b837>] inet_ioctl+0x89/0xaa
                          [<c0249cd1>] sock_ioctl+0x1ac/0x1ca
                          [<c0170a70>] do_ioctl+0x1c/0x53
                          [<c0170c93>] vfs_ioctl+0x1ec/0x203
                          [<c0170cf3>] sys_ioctl+0x49/0x62
                          [<c0103ca8>] sysenter_past_esp+0x5d/0x99
                          [<ffffffff>] 0xffffffff
  }
  ... key      at: [<c05f0788>] __key.29726+0x0/0x8
  -> (&rp->lock){++..} ops: 55 {
     initial-use  at:
                            [<c012f664>] __lock_acquire+0x486/0xb93
                            [<c012fdd9>] lock_acquire+0x68/0x82
                            [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
                            [<d88a810a>] rhine_get_stats+0x2d/0x9d
[via_rhine]
                            [<c025ab78>] rtnl_fill_ifinfo+0x2ea/0x432
                            [<c025b0d7>] rtmsg_ifinfo+0x63/0xe0
                            [<c025b18f>] rtnetlink_event+0x3b/0x3f
                            [<c012020a>] notifier_call_chain+0x2b/0x4a
                            [<c0120294>] __raw_notifier_call_chain
+0x19/0x1f
                            [<c01202b4>] raw_notifier_call_chain
+0x1a/0x1c
                            [<c025304c>] register_netdevice+0x2e0/0x2ea
                            [<c0254284>] register_netdev+0x40/0x4d
                            [<d88a7c8c>] rhine_init_one+0x495/0x652
[via_rhine]
                            [<c01d5951>] pci_device_probe+0x3c/0x61
                            [<c0223684>] driver_probe_device+0xe8/0x168
                            [<c0223831>] __driver_attach+0x77/0xb1
                            [<c0222b5a>] bus_for_each_dev+0x3a/0x5f
                            [<c02234c7>] driver_attach+0x19/0x1b
                            [<c0222e7f>] bus_add_driver+0x76/0x17e
                            [<c0223a60>] driver_register+0x79/0x7f
                            [<c01d5ac6>] __pci_register_driver+0x5c/0x8c
                            [<d883c06c>] __ksymtab_ac97_bus_type
+0x0/0xfffffff6 [ac97_bus]
                            [<c01365eb>] sys_init_module+0x1252/0x138f
                            [<c0103ca8>] sysenter_past_esp+0x5d/0x99
                            [<ffffffff>] 0xffffffff
     in-hardirq-W at:
                            [<c012f58e>] __lock_acquire+0x3b0/0xb93
                            [<c012fdd9>] lock_acquire+0x68/0x82
                            [<c02aaeed>] _spin_lock+0x2b/0x38
                            [<d88a6b56>] rhine_interrupt+0x16a/0x696
[via_rhine]
                            [<c0142d2e>] handle_IRQ_event+0x1a/0x48
                            [<c014403e>] handle_level_irq+0x7c/0xc6
                            [<c01057eb>] do_IRQ+0x59/0x76
                            [<c0103f16>] common_interrupt+0x2e/0x34
                            [<c0123db9>] rcu_process_callbacks+0x15/0x26
                            [<c011a682>] tasklet_action+0x40/0x6c
                            [<c011a5a6>] __do_softirq+0x46/0x9c
                            [<c011a629>] do_softirq+0x2d/0x46
                            [<c011a9d5>] irq_exit+0x3b/0x6b
                            [<c01057f0>] do_IRQ+0x5e/0x76
                            [<c0103f16>] common_interrupt+0x2e/0x34
                            [<c02ab3b9>] error_code+0x71/0x78
                            [<ffffffff>] 0xffffffff
     in-softirq-W at:
                            [<c012f5b5>] __lock_acquire+0x3d7/0xb93
                            [<c012fdd9>] lock_acquire+0x68/0x82
                            [<c02ab158>] _spin_lock_irq+0x31/0x3e
                            [<d88a8614>] rhine_start_tx+0x1ad/0x244
[via_rhine]
                            [<c0253b4c>] dev_hard_start_xmit+0x216/0x274
                            [<c02606dc>] __qdisc_run+0xca/0x17f
                            [<c0255766>] dev_queue_xmit+0x155/0x26b
                            [<d8c52c05>] mld_sendpack+0x1f7/0x335 [ipv6]
                            [<d8c538ce>] mld_ifc_timer_expire
+0x1f6/0x21d [ipv6]
                            [<c011cbd6>] run_timer_softirq+0xf1/0x14e
                            [<c011a5a6>] __do_softirq+0x46/0x9c
                            [<c011a629>] do_softirq+0x2d/0x46
                            [<c011a9d5>] irq_exit+0x3b/0x6b
                            [<c01057f0>] do_IRQ+0x5e/0x76
                            [<c0103f16>] common_interrupt+0x2e/0x34
                            [<c02ab3b9>] error_code+0x71/0x78
                            [<ffffffff>] 0xffffffff
   }
   ... key      at: [<d88ac180>] __key.21685+0x0/0xffffc5fa [via_rhine]
  ... acquired at:
   [<c012fbc6>] __lock_acquire+0x9e8/0xb93
   [<c012fdd9>] lock_acquire+0x68/0x82
   [<c02ab158>] _spin_lock_irq+0x31/0x3e
   [<d88a8614>] rhine_start_tx+0x1ad/0x244 [via_rhine]
   [<c0253b4c>] dev_hard_start_xmit+0x216/0x274
   [<c02606dc>] __qdisc_run+0xca/0x17f
   [<c0255766>] dev_queue_xmit+0x155/0x26b
   [<d8c52c05>] mld_sendpack+0x1f7/0x335 [ipv6]
   [<d8c538ce>] mld_ifc_timer_expire+0x1f6/0x21d [ipv6]
   [<c011cbd6>] run_timer_softirq+0xf1/0x14e
   [<c011a5a6>] __do_softirq+0x46/0x9c
   [<c011a629>] do_softirq+0x2d/0x46
   [<c011a9d5>] irq_exit+0x3b/0x6b
   [<c01057f0>] do_IRQ+0x5e/0x76
   [<c0103f16>] common_interrupt+0x2e/0x34
   [<c02ab3b9>] error_code+0x71/0x78
   [<ffffffff>] 0xffffffff

 ... acquired at:
   [<c012fbc6>] __lock_acquire+0x9e8/0xb93
   [<c012fdd9>] lock_acquire+0x68/0x82
   [<c02aaf2a>] _spin_lock_bh+0x30/0x3d
   [<c02569c5>] dev_mc_add+0x33/0x141
   [<d8c539c0>] igmp6_group_added+0x58/0x120 [ipv6]
   [<d8c54175>] ipv6_dev_mc_inc+0x2f9/0x346 [ipv6]
   [<d8c42f7f>] ipv6_add_dev+0x232/0x240 [ipv6]
   [<d8c43503>] addrconf_notify+0x47/0x7d0 [ipv6]
   [<c0253ddc>] register_netdevice_notifier+0x35/0x5f
   [<d8c14336>] ____versions+0x1eb6/0xfffff9c8 [x_tables]
   [<d8c141d4>] ____versions+0x1d54/0xfffff9c8 [x_tables]
   [<c01365eb>] sys_init_module+0x1252/0x138f
   [<c0103ca8>] sysenter_past_esp+0x5d/0x99
   [<ffffffff>] 0xffffffff

 -> (&parent->list_lock){++..} ops: 14182 {
    initial-use  at:
                          [<c012f664>] __lock_acquire+0x486/0xb93
                          [<c012fdd9>] lock_acquire+0x68/0x82
                          [<c02aaeed>] _spin_lock+0x2b/0x38
                          [<c01637a4>] cache_alloc_refill+0x4f/0x44f
                          [<c0163d52>] kmem_cache_zalloc+0x50/0x97
                          [<c01643cc>] kmem_cache_create+0x166/0x447
                          [<c039804a>] kmem_cache_init+0x160/0x3c7
                          [<c0388ab4>] start_kernel+0x217/0x38d
                          [<00000000>] 0x0
                          [<ffffffff>] 0xffffffff
    in-hardirq-W at:
                          [<c012f58e>] __lock_acquire+0x3b0/0xb93
                          [<c012fdd9>] lock_acquire+0x68/0x82
                          [<c02aaeed>] _spin_lock+0x2b/0x38
                          [<c01630e3>] cache_flusharray+0x22/0xa5
                          [<c0163254>] kmem_cache_free+0x62/0x8e
                          [<c014c6cb>] mempool_free_slab+0x11/0x13
                          [<c014c731>] mempool_free+0x64/0x6c
                          [<c0185212>] bio_free+0x2d/0x31
                          [<c0185227>] bio_fs_destructor+0x11/0x13
                          [<c018534c>] bio_put+0x28/0x2a
                          [<c01839f2>] end_bio_bh_io_sync+0x39/0x3f
                          [<c018527c>] bio_endio+0x53/0x5b
                          [<c01b49fa>] __end_that_request_first
+0xcf/0x35d
                          [<c01b4ca3>] end_that_request_first+0xe/0x10
                          [<d895ec75>] ide_end_request+0x87/0xd1
[ide_core]
                          [<d8965d80>] ide_dma_intr+0x58/0x98 [ide_core]
                          [<d895f7fe>] ide_intr+0x16b/0x1cf [ide_core]
                          [<c0142d2e>] handle_IRQ_event+0x1a/0x48
                          [<c014403e>] handle_level_irq+0x7c/0xc6
                          [<c01057eb>] do_IRQ+0x59/0x76
                          [<c0103f16>] common_interrupt+0x2e/0x34
                          [<c010239b>] cpu_idle+0x44/0x5e
                          [<c0101110>] rest_init+0x21/0x25
                          [<c0388c22>] start_kernel+0x385/0x38d
                          [<00000000>] 0x0
                          [<ffffffff>] 0xffffffff
    in-softirq-W at:
                          [<c012f5b5>] __lock_acquire+0x3d7/0xb93
                          [<c012fdd9>] lock_acquire+0x68/0x82
                          [<c02aaeed>] _spin_lock+0x2b/0x38
                          [<c01630e3>] cache_flusharray+0x22/0xa5
                          [<c01631c4>] kfree+0x5e/0x8c
                          [<c0114875>] free_task+0x11/0x21
                          [<c01160c3>] __put_task_struct+0x10f/0x118
                          [<c01178cd>] delayed_put_task_struct+0x3e/0x45
                          [<c0123d3b>] __rcu_process_callbacks
+0x103/0x16c
                          [<c0123db9>] rcu_process_callbacks+0x15/0x26
                          [<c011a682>] tasklet_action+0x40/0x6c
                          [<c011a5a6>] __do_softirq+0x46/0x9c
                          [<c011a629>] do_softirq+0x2d/0x46
                          [<c011a9d5>] irq_exit+0x3b/0x6b
                          [<c01057f0>] do_IRQ+0x5e/0x76
                          [<c0103f16>] common_interrupt+0x2e/0x34
                          [<c01ed01e>] acpi_ps_alloc_op+0x5b/0x98
                          [<c01ecc85>] acpi_ps_parse_loop+0x6d9/0x714
                          [<c01ebf86>] acpi_ps_parse_aml+0x68/0x246
                          [<c01ed236>] acpi_ps_execute_method
+0x11f/0x1c1
                          [<c01ea44c>] acpi_ns_evaluate+0xa0/0x100
                          [<c01efba8>] acpi_ut_evaluate_object
+0x52/0x18c
                          [<c01e226e>] acpi_ev_match_prw_and_gpe
+0x1f/0xbe
                          [<c01eb6b9>] acpi_ns_walk_namespace+0xf9/0x114
                          [<c01e2216>] acpi_ev_initialize_gpe_block
+0x4d/0x86
                          [<c01dfe20>] acpi_ev_install_fadt_gpes
+0x27/0x47
                          [<c01f0ace>] acpi_enable_subsystem+0x83/0x8f
                          [<c039af8c>] acpi_init+0x57/0x1cd
                          [<c038872c>] kernel_init+0xb9/0x22a
                          [<c0104007>] kernel_thread_helper+0x7/0x10
                          [<ffffffff>] 0xffffffff
  }
  ... key      at: [<c05e5a88>] __key.17030+0x0/0x8
  -> (&zone->lock){++..} ops: 6654 {
     initial-use  at:
                            [<c012f664>] __lock_acquire+0x486/0xb93
                            [<c012fdd9>] lock_acquire+0x68/0x82
                            [<c02aaeed>] _spin_lock+0x2b/0x38
                            [<c014dbc8>] free_pages_bulk+0x1a/0x195
                            [<c014de55>] free_hot_cold_page+0x112/0x156
                            [<c014dee4>] free_hot_page+0xd/0xf
                            [<c014df1e>] __free_pages+0x38/0x4a
                            [<c03977a4>] __free_pages_bootmem+0x61/0x65
                            [<c0395fb4>] free_all_bootmem_core
+0xd6/0x147
                            [<c0396035>] free_all_bootmem+0x10/0x12
                            [<c0393631>] mem_init+0x2a/0x2d0
                            [<c0388aaf>] start_kernel+0x212/0x38d
                            [<00000000>] 0x0
                            [<ffffffff>] 0xffffffff
     in-hardirq-W at:
                            [<c012f58e>] __lock_acquire+0x3b0/0xb93
                            [<c012fdd9>] lock_acquire+0x68/0x82
                            [<c02aaeed>] _spin_lock+0x2b/0x38
                            [<c014dbc8>] free_pages_bulk+0x1a/0x195
                            [<c014de55>] free_hot_cold_page+0x112/0x156
                            [<c014dee4>] free_hot_page+0xd/0xf
                            [<c014df1e>] __free_pages+0x38/0x4a
                            [<c014df50>] free_pages+0x20/0x22
                            [<c0163060>] kmem_freepages+0x9c/0xa4
                            [<c016331e>] slab_destroy+0x61/0x79
                            [<c01633ed>] free_block+0xb7/0xf4
                            [<c0163138>] cache_flusharray+0x77/0xa5
                            [<c0163254>] kmem_cache_free+0x62/0x8e
                            [<c014c6cb>] mempool_free_slab+0x11/0x13
                            [<c014c731>] mempool_free+0x64/0x6c
                            [<c0185212>] bio_free+0x2d/0x31
                            [<c0185227>] bio_fs_destructor+0x11/0x13
                            [<c018534c>] bio_put+0x28/0x2a
                            [<c01839f2>] end_bio_bh_io_sync+0x39/0x3f
                            [<c018527c>] bio_endio+0x53/0x5b
                            [<c01b49fa>] __end_that_request_first
+0xcf/0x35d
                            [<c01b4ca3>] end_that_request_first+0xe/0x10
                            [<d895ec75>] ide_end_request+0x87/0xd1
[ide_core]
                            [<d8965d80>] ide_dma_intr+0x58/0x98
[ide_core]
                            [<d895f7fe>] ide_intr+0x16b/0x1cf [ide_core]
                            [<c0142d2e>] handle_IRQ_event+0x1a/0x48
                            [<c014403e>] handle_level_irq+0x7c/0xc6
                            [<c01057eb>] do_IRQ+0x59/0x76
                            [<c0103f16>] common_interrupt+0x2e/0x34
                            [<c010239b>] cpu_idle+0x44/0x5e
                            [<c0101110>] rest_init+0x21/0x25
                            [<c0388c22>] start_kernel+0x385/0x38d
                            [<00000000>] 0x0
                            [<ffffffff>] 0xffffffff
     in-softirq-W at:
                            [<c012f5b5>] __lock_acquire+0x3d7/0xb93
                            [<c012fdd9>] lock_acquire+0x68/0x82
                            [<c02aaeed>] _spin_lock+0x2b/0x38
                            [<c014da1c>] __free_pages_ok+0xf6/0x278
                            [<c014df29>] __free_pages+0x43/0x4a
                            [<c014df50>] free_pages+0x20/0x22
                            [<c0163060>] kmem_freepages+0x9c/0xa4
                            [<c016331e>] slab_destroy+0x61/0x79
                            [<c01633ed>] free_block+0xb7/0xf4
                            [<c0163138>] cache_flusharray+0x77/0xa5
                            [<c01631c4>] kfree+0x5e/0x8c
                            [<c0114875>] free_task+0x11/0x21
                            [<c01160c3>] __put_task_struct+0x10f/0x118
                            [<c01178cd>] delayed_put_task_struct
+0x3e/0x45
                            [<c0123d3b>] __rcu_process_callbacks
+0x103/0x16c
                            [<c0123db9>] rcu_process_callbacks+0x15/0x26
                            [<c011a682>] tasklet_action+0x40/0x6c
                            [<c011a5a6>] __do_softirq+0x46/0x9c
                            [<c011a629>] do_softirq+0x2d/0x46
                            [<c011a9d5>] irq_exit+0x3b/0x6b
                            [<c01057f0>] do_IRQ+0x5e/0x76
                            [<c0103f16>] common_interrupt+0x2e/0x34
                            [<c02a9e79>] __mutex_lock_slowpath
+0x238/0x240
                            [<c02a9ea5>] mutex_lock+0x24/0x28
                            [<c016c7b2>] do_lookup+0x69/0x13d
                            [<c016e6d6>] __link_path_walk+0x814/0xc69
                            [<c016eb74>] link_path_walk+0x49/0xbc
                            [<c016ee96>] do_path_lookup+0x18a/0x1dc
                            [<c016f822>] __path_lookup_intent_open
+0x44/0x75
                            [<c016f8c6>] path_lookup_open+0x21/0x27
                            [<c0169bc9>] open_exec+0x27/0xa5
                            [<c016aeaa>] do_execve+0x36/0x1f1
                            [<c01021a3>] sys_execve+0x2e/0x50
                            [<c0103d34>] syscall_call+0x7/0xb
                            [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c05de598>] __key.20983+0x0/0x8
  ... acquired at:
   [<c012fbc6>] __lock_acquire+0x9e8/0xb93
   [<c012fdd9>] lock_acquire+0x68/0x82
   [<c02aaeed>] _spin_lock+0x2b/0x38
   [<c014da1c>] __free_pages_ok+0xf6/0x278
   [<c014df29>] __free_pages+0x43/0x4a
   [<c014df50>] free_pages+0x20/0x22
   [<c0163060>] kmem_freepages+0x9c/0xa4
   [<c016331e>] slab_destroy+0x61/0x79
   [<c01633ed>] free_block+0xb7/0xf4
   [<c0163138>] cache_flusharray+0x77/0xa5
   [<c01631c4>] kfree+0x5e/0x8c
   [<c0114875>] free_task+0x11/0x21
   [<c01160c3>] __put_task_struct+0x10f/0x118
   [<c01178cd>] delayed_put_task_struct+0x3e/0x45
   [<c0123d3b>] __rcu_process_callbacks+0x103/0x16c
   [<c0123db9>] rcu_process_callbacks+0x15/0x26
   [<c011a682>] tasklet_action+0x40/0x6c
   [<c011a5a6>] __do_softirq+0x46/0x9c
   [<c011a629>] do_softirq+0x2d/0x46
   [<c011a9d5>] irq_exit+0x3b/0x6b
   [<c01057f0>] do_IRQ+0x5e/0x76
   [<c0103f16>] common_interrupt+0x2e/0x34
   [<c02a9e79>] __mutex_lock_slowpath+0x238/0x240
   [<c02a9ea5>] mutex_lock+0x24/0x28
   [<c016c7b2>] do_lookup+0x69/0x13d
   [<c016e6d6>] __link_path_walk+0x814/0xc69
   [<c016eb74>] link_path_walk+0x49/0xbc
   [<c016ee96>] do_path_lookup+0x18a/0x1dc
   [<c016f822>] __path_lookup_intent_open+0x44/0x75
   [<c016f8c6>] path_lookup_open+0x21/0x27
   [<c0169bc9>] open_exec+0x27/0xa5
   [<c016aeaa>] do_execve+0x36/0x1f1
   [<c01021a3>] sys_execve+0x2e/0x50
   [<c0103d34>] syscall_call+0x7/0xb
   [<ffffffff>] 0xffffffff

  -> (pgd_lock){....} ops: 119 {
     initial-use  at:
                            [<c012f664>] __lock_acquire+0x486/0xb93
                            [<c012fdd9>] lock_acquire+0x68/0x82
                            [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
                            [<c0110d8a>] pgd_ctor+0x25/0x7d
                            [<c0163aee>] cache_alloc_refill+0x399/0x44f
                            [<c016372d>] kmem_cache_alloc+0x50/0x78
                            [<c0110d1f>] pgd_alloc+0x15/0x17
                            [<c0114691>] mm_init+0xa6/0xcd
                            [<c0115bbd>] mm_alloc+0x2e/0x32
                            [<c016aedd>] do_execve+0x69/0x1f1
                            [<c01021a3>] sys_execve+0x2e/0x50
                            [<c0103d34>] syscall_call+0x7/0xb
                            [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c0361cfc>] pgd_lock+0x1c/0x40
  ... acquired at:
   [<c012fbc6>] __lock_acquire+0x9e8/0xb93
   [<c012fdd9>] lock_acquire+0x68/0x82
   [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
   [<c0110d34>] pgd_dtor+0x13/0x44
   [<c01632f0>] slab_destroy+0x33/0x79
   [<c01633ed>] free_block+0xb7/0xf4
   [<c0163138>] cache_flusharray+0x77/0xa5
   [<c0163254>] kmem_cache_free+0x62/0x8e
   [<c0110d08>] pgd_free+0x12/0x14
   [<c011477d>] __mmdrop+0x1c/0x33
   [<c02a8dce>] __sched_text_start+0x546/0x59f
   [<c01188da>] do_wait+0x90e/0xa04
   [<c0118a00>] sys_wait4+0x30/0x32
   [<c0118a29>] sys_waitpid+0x27/0x29
   [<c0103ca8>] sysenter_past_esp+0x5d/0x99
   [<ffffffff>] 0xffffffff

 ... acquired at:
   [<c012fbc6>] __lock_acquire+0x9e8/0xb93
   [<c012fdd9>] lock_acquire+0x68/0x82
   [<c02aaeed>] _spin_lock+0x2b/0x38
   [<c01637a4>] cache_alloc_refill+0x4f/0x44f
   [<c0163c19>] __kmalloc+0x75/0x9a
   [<c024f856>] __alloc_skb+0x6b/0x11b
   [<c024c162>] sock_alloc_send_skb+0x7c/0x1a9
   [<d8c52299>] mld_newpack+0x5d/0x172 [ipv6]
   [<d8c523d2>] add_grhead+0x24/0xa4 [ipv6]
   [<d8c53072>] add_grec+0x32f/0x35a [ipv6]
   [<d8c5389f>] mld_ifc_timer_expire+0x1c7/0x21d [ipv6]
   [<c011cbd6>] run_timer_softirq+0xf1/0x14e
   [<c011a5a6>] __do_softirq+0x46/0x9c
   [<c011a629>] do_softirq+0x2d/0x46
   [<c011a9d5>] irq_exit+0x3b/0x6b
   [<c01057f0>] do_IRQ+0x5e/0x76
   [<c0103f16>] common_interrupt+0x2e/0x34
   [<c02ab3b9>] error_code+0x71/0x78
   [<ffffffff>] 0xffffffff


the soft-irq-unsafe lock's dependencies:
-> (&priv->lock){--..} ops: 2 {
   initial-use  at:
                        [<c012f664>] __lock_acquire+0x486/0xb93
                        [<c012fdd9>] lock_acquire+0x68/0x82
                        [<c02aaeed>] _spin_lock+0x2b/0x38
                        [<d886b729>] sc92031_open+0xcc/0x16f [sc92031]
                        [<c02549e7>] dev_open+0x33/0x6e
                        [<c025337f>] dev_change_flags+0x57/0x10b
                        [<c028b237>] devinet_ioctl+0x235/0x546
                        [<c028b837>] inet_ioctl+0x89/0xaa
                        [<c0249cd1>] sock_ioctl+0x1ac/0x1ca
                        [<c0170a70>] do_ioctl+0x1c/0x53
                        [<c0170c93>] vfs_ioctl+0x1ec/0x203
                        [<c0170cf3>] sys_ioctl+0x49/0x62
                        [<c0103ca8>] sysenter_past_esp+0x5d/0x99
                        [<ffffffff>] 0xffffffff
   softirq-on-W at:
                        [<c012f649>] __lock_acquire+0x46b/0xb93
                        [<c012fdd9>] lock_acquire+0x68/0x82
                        [<c02aaeed>] _spin_lock+0x2b/0x38
                        [<d886b729>] sc92031_open+0xcc/0x16f [sc92031]
                        [<c02549e7>] dev_open+0x33/0x6e
                        [<c025337f>] dev_change_flags+0x57/0x10b
                        [<c028b237>] devinet_ioctl+0x235/0x546
                        [<c028b837>] inet_ioctl+0x89/0xaa
                        [<c0249cd1>] sock_ioctl+0x1ac/0x1ca
                        [<c0170a70>] do_ioctl+0x1c/0x53
                        [<c0170c93>] vfs_ioctl+0x1ec/0x203
                        [<c0170cf3>] sys_ioctl+0x49/0x62
                        [<c0103ca8>] sysenter_past_esp+0x5d/0x99
                        [<ffffffff>] 0xffffffff
   hardirq-on-W at:
                        [<c012f61f>] __lock_acquire+0x441/0xb93
                        [<c012fdd9>] lock_acquire+0x68/0x82
                        [<c02aaeed>] _spin_lock+0x2b/0x38
                        [<d886b729>] sc92031_open+0xcc/0x16f [sc92031]
                        [<c02549e7>] dev_open+0x33/0x6e
                        [<c025337f>] dev_change_flags+0x57/0x10b
                        [<c028b237>] devinet_ioctl+0x235/0x546
                        [<c028b837>] inet_ioctl+0x89/0xaa
                        [<c0249cd1>] sock_ioctl+0x1ac/0x1ca
                        [<c0170a70>] do_ioctl+0x1c/0x53
                        [<c0170c93>] vfs_ioctl+0x1ec/0x203
                        [<c0170cf3>] sys_ioctl+0x49/0x62
                        [<c0103ca8>] sysenter_past_esp+0x5d/0x99
                        [<ffffffff>] 0xffffffff
 }
 ... key      at: [<d886e180>] __key.22056+0x0/0xffffd670 [sc92031]
 -> (lweventlist_lock){....} ops: 1 {
    initial-use  at:
                          [<c012f664>] __lock_acquire+0x486/0xb93
                          [<c012fdd9>] lock_acquire+0x68/0x82
                          [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
                          [<c025c17a>] linkwatch_fire_event+0x58/0xae
                          [<c02605e3>] netif_carrier_off+0x1a/0x1c
                          [<d886a650>] _sc92031_reset+0x1a5/0x1dd
[sc92031]
                          [<d886b730>] sc92031_open+0xd3/0x16f [sc92031]
                          [<c02549e7>] dev_open+0x33/0x6e
                          [<c025337f>] dev_change_flags+0x57/0x10b
                          [<c028b237>] devinet_ioctl+0x235/0x546
                          [<c028b837>] inet_ioctl+0x89/0xaa
                          [<c0249cd1>] sock_ioctl+0x1ac/0x1ca
                          [<c0170a70>] do_ioctl+0x1c/0x53
                          [<c0170c93>] vfs_ioctl+0x1ec/0x203
                          [<c0170cf3>] sys_ioctl+0x49/0x62
                          [<c0103ca8>] sysenter_past_esp+0x5d/0x99
                          [<ffffffff>] 0xffffffff
  }
  ... key      at: [<c037a19c>] lweventlist_lock+0x1c/0x28
 ... acquired at:
   [<c012fbc6>] __lock_acquire+0x9e8/0xb93
   [<c012fdd9>] lock_acquire+0x68/0x82
   [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
   [<c025c17a>] linkwatch_fire_event+0x58/0xae
   [<c02605e3>] netif_carrier_off+0x1a/0x1c
   [<d886a650>] _sc92031_reset+0x1a5/0x1dd [sc92031]
   [<d886b730>] sc92031_open+0xd3/0x16f [sc92031]
   [<c02549e7>] dev_open+0x33/0x6e
   [<c025337f>] dev_change_flags+0x57/0x10b
   [<c028b237>] devinet_ioctl+0x235/0x546
   [<c028b837>] inet_ioctl+0x89/0xaa
   [<c0249cd1>] sock_ioctl+0x1ac/0x1ca
   [<c0170a70>] do_ioctl+0x1c/0x53
   [<c0170c93>] vfs_ioctl+0x1ec/0x203
   [<c0170cf3>] sys_ioctl+0x49/0x62
   [<c0103ca8>] sysenter_past_esp+0x5d/0x99
   [<ffffffff>] 0xffffffff

 -> (&cwq->lock){++..} ops: 8986 {
    initial-use  at:
                          [<c012f664>] __lock_acquire+0x486/0xb93
                          [<c012fdd9>] lock_acquire+0x68/0x82
                          [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
                          [<c0123109>] __queue_work+0x12/0x33
                          [<c0123152>] queue_work+0x28/0x33
                          [<c012293e>] call_usermodehelper_keys
+0xc5/0xea
                          [<c01bf6ca>] kobject_uevent_env+0x3d3/0x42b
                          [<c01bf72f>] kobject_uevent+0xd/0x12
                          [<c022184a>] device_add+0x32f/0x518
                          [<c0221a48>] device_register+0x15/0x19
                          [<c0221faa>] device_create+0x77/0x99
                          [<c039e0d0>] vtconsole_class_init+0x71/0xb5
                          [<c038872c>] kernel_init+0xb9/0x22a
                          [<c0104007>] kernel_thread_helper+0x7/0x10
                          [<ffffffff>] 0xffffffff
    in-hardirq-W at:
                          [<c012f58e>] __lock_acquire+0x3b0/0xb93
                          [<c012fdd9>] lock_acquire+0x68/0x82
                          [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
                          [<c0123109>] __queue_work+0x12/0x33
                          [<c0123152>] queue_work+0x28/0x33
                          [<c012316f>] schedule_work+0x12/0x14
                          [<c0229e72>] schedule_bh+0x15/0x17
                          [<c0229ff8>] floppy_interrupt+0x168/0x192
                          [<c022d014>] floppy_hardint+0x1c/0xbc
                          [<c0142d2e>] handle_IRQ_event+0x1a/0x48
                          [<c014403e>] handle_level_irq+0x7c/0xc6
                          [<c01057eb>] do_IRQ+0x59/0x76
                          [<c0103f16>] common_interrupt+0x2e/0x34
                          [<c010239b>] cpu_idle+0x44/0x5e
                          [<c0101110>] rest_init+0x21/0x25
                          [<c0388c22>] start_kernel+0x385/0x38d
                          [<00000000>] 0x0
                          [<ffffffff>] 0xffffffff
    in-softirq-W at:
                          [<c012f5b5>] __lock_acquire+0x3d7/0xb93
                          [<c012fdd9>] lock_acquire+0x68/0x82
                          [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
                          [<c0123109>] __queue_work+0x12/0x33
                          [<c01234b5>] delayed_work_timer_fn+0x17/0x19
                          [<c011cbd6>] run_timer_softirq+0xf1/0x14e
                          [<c011a5a6>] __do_softirq+0x46/0x9c
                          [<c011a629>] do_softirq+0x2d/0x46
                          [<c011a9d5>] irq_exit+0x3b/0x6b
                          [<c01057f0>] do_IRQ+0x5e/0x76
                          [<c0103f16>] common_interrupt+0x2e/0x34
                          [<c010239b>] cpu_idle+0x44/0x5e
                          [<c0101110>] rest_init+0x21/0x25
                          [<c0388c22>] start_kernel+0x385/0x38d
                          [<00000000>] 0x0
                          [<ffffffff>] 0xffffffff
  }
  ... key      at: [<c03e22e0>] __key.10619+0x0/0x8
  -> (&q->lock){++..} ops: 54469 {
     initial-use  at:
                            [<c012f664>] __lock_acquire+0x486/0xb93
                            [<c012fdd9>] lock_acquire+0x68/0x82
                            [<c02ab158>] _spin_lock_irq+0x31/0x3e
                            [<c02a8fb9>] wait_for_completion+0x29/0xaf
                            [<c012599d>] keventd_create_kthread
+0x32/0x62
                            [<c0125a30>] kthread_create+0x63/0x9e
                            [<c0394848>] cpu_callback+0x35/0x7a
                            [<c03948a4>] spawn_ksoftirqd+0x17/0x37
                            [<c03886ac>] kernel_init+0x39/0x22a
                            [<c0104007>] kernel_thread_helper+0x7/0x10
                            [<ffffffff>] 0xffffffff
     in-hardirq-W at:
                            [<c012f58e>] __lock_acquire+0x3b0/0xb93
                            [<c012fdd9>] lock_acquire+0x68/0x82
                            [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
                            [<c0112ae3>] __wake_up+0x15/0x42
                            [<c0122d39>] insert_work+0x64/0x6b
                            [<c0123119>] __queue_work+0x22/0x33
                            [<c0123152>] queue_work+0x28/0x33
                            [<c012316f>] schedule_work+0x12/0x14
                            [<c0229e72>] schedule_bh+0x15/0x17
                            [<c0229ff8>] floppy_interrupt+0x168/0x192
                            [<c022d014>] floppy_hardint+0x1c/0xbc
                            [<c0142d2e>] handle_IRQ_event+0x1a/0x48
                            [<c014403e>] handle_level_irq+0x7c/0xc6
                            [<c01057eb>] do_IRQ+0x59/0x76
                            [<c0103f16>] common_interrupt+0x2e/0x34
                            [<c010239b>] cpu_idle+0x44/0x5e
                            [<c0101110>] rest_init+0x21/0x25
                            [<c0388c22>] start_kernel+0x385/0x38d
                            [<00000000>] 0x0
                            [<ffffffff>] 0xffffffff
     in-softirq-W at:
                            [<c012f5b5>] __lock_acquire+0x3d7/0xb93
                            [<c012fdd9>] lock_acquire+0x68/0x82
                            [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
                            [<c0112a4f>] complete+0x15/0x4a
                            [<c0123b65>] wakeme_after_rcu+0xe/0x10
                            [<c0123d3b>] __rcu_process_callbacks
+0x103/0x16c
                            [<c0123db9>] rcu_process_callbacks+0x15/0x26
                            [<c011a682>] tasklet_action+0x40/0x6c
                            [<c011a5a6>] __do_softirq+0x46/0x9c
                            [<c011a629>] do_softirq+0x2d/0x46
                            [<c011a9d5>] irq_exit+0x3b/0x6b
                            [<c01057f0>] do_IRQ+0x5e/0x76
                            [<c0103f16>] common_interrupt+0x2e/0x34
                            [<c010239b>] cpu_idle+0x44/0x5e
                            [<c0101110>] rest_init+0x21/0x25
                            [<c0388c22>] start_kernel+0x385/0x38d
                            [<00000000>] 0x0
                            [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c03e271c>] __key.14042+0x0/0x8
   -> (&rq->rq_lock_key){++..} ops: 67981 {
      initial-use  at:
                              [<c012f664>] __lock_acquire+0x486/0xb93
                              [<c012fdd9>] lock_acquire+0x68/0x82
                              [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
                              [<c0393e8d>] init_idle+0x5c/0x86
                              [<c03940cb>] sched_init+0x214/0x21c
                              [<c038897a>] start_kernel+0xdd/0x38d
                              [<00000000>] 0x0
                              [<ffffffff>] 0xffffffff
      in-hardirq-W at:
                              [<c012f58e>] __lock_acquire+0x3b0/0xb93
                              [<c012fdd9>] lock_acquire+0x68/0x82
                              [<c02aaeed>] _spin_lock+0x2b/0x38
                              [<c0114195>] scheduler_tick+0x8e/0xbd
                              [<c011d1bf>] update_process_times
+0x4f/0x5a
                              [<c012bf0d>] tick_periodic+0x69/0x75
                              [<c012bf2b>] tick_handle_periodic
+0x12/0x63
                              [<c01066d9>] timer_interrupt+0x11/0x18
                              [<c0142d2e>] handle_IRQ_event+0x1a/0x48
                              [<c014403e>] handle_level_irq+0x7c/0xc6
                              [<c01057eb>] do_IRQ+0x59/0x76
                              [<c0103f16>] common_interrupt+0x2e/0x34
                              [<c038f206>] request_standard_resources
+0x75/0x2fc
                              [<c038872c>] kernel_init+0xb9/0x22a
                              [<c0104007>] kernel_thread_helper+0x7/0x10
                              [<ffffffff>] 0xffffffff
      in-softirq-W at:
                              [<c012f5b5>] __lock_acquire+0x3d7/0xb93
                              [<c012fdd9>] lock_acquire+0x68/0x82
                              [<c02aaeed>] _spin_lock+0x2b/0x38
                              [<c0113260>] task_rq_lock+0x1a/0x21
                              [<c0113944>] try_to_wake_up+0x18/0xa0
                              [<c01139da>] default_wake_function
+0xe/0x10
                              [<c01127f0>] __wake_up_common+0x32/0x55
                              [<c0112a73>] complete+0x39/0x4a
                              [<c0123b65>] wakeme_after_rcu+0xe/0x10
                              [<c0123d3b>] __rcu_process_callbacks
+0x103/0x16c
                              [<c0123db9>] rcu_process_callbacks
+0x15/0x26
                              [<c011a682>] tasklet_action+0x40/0x6c
                              [<c011a5a6>] __do_softirq+0x46/0x9c
                              [<c011a629>] do_softirq+0x2d/0x46
                              [<c011a9d5>] irq_exit+0x3b/0x6b
                              [<c01057f0>] do_IRQ+0x5e/0x76
                              [<c0103f16>] common_interrupt+0x2e/0x34
                              [<c010239b>] cpu_idle+0x44/0x5e
                              [<c0101110>] rest_init+0x21/0x25
                              [<c0388c22>] start_kernel+0x385/0x38d
                              [<00000000>] 0x0
                              [<ffffffff>] 0xffffffff
    }
    ... key      at: [<c03bfd38>] per_cpu__runqueues+0x9f8/0xa00
   ... acquired at:
   [<c012fbc6>] __lock_acquire+0x9e8/0xb93
   [<c012fdd9>] lock_acquire+0x68/0x82
   [<c02aaeed>] _spin_lock+0x2b/0x38
   [<c0113260>] task_rq_lock+0x1a/0x21
   [<c0113944>] try_to_wake_up+0x18/0xa0
   [<c01139da>] default_wake_function+0xe/0x10
   [<c01127f0>] __wake_up_common+0x32/0x55
   [<c0112a73>] complete+0x39/0x4a
   [<c0125af2>] kthread+0x87/0xcd
   [<c0104007>] kernel_thread_helper+0x7/0x10
   [<ffffffff>] 0xffffffff

  ... acquired at:
   [<c012fbc6>] __lock_acquire+0x9e8/0xb93
   [<c012fdd9>] lock_acquire+0x68/0x82
   [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
   [<c0112ae3>] __wake_up+0x15/0x42
   [<c0122d39>] insert_work+0x64/0x6b
   [<c0123119>] __queue_work+0x22/0x33
   [<c0123152>] queue_work+0x28/0x33
   [<c012293e>] call_usermodehelper_keys+0xc5/0xea
   [<c01bf6ca>] kobject_uevent_env+0x3d3/0x42b
   [<c01bf72f>] kobject_uevent+0xd/0x12
   [<c022184a>] device_add+0x32f/0x518
   [<c0221a48>] device_register+0x15/0x19
   [<c0221faa>] device_create+0x77/0x99
   [<c039e0d0>] vtconsole_class_init+0x71/0xb5
   [<c038872c>] kernel_init+0xb9/0x22a
   [<c0104007>] kernel_thread_helper+0x7/0x10
   [<ffffffff>] 0xffffffff

 ... acquired at:
   [<c012fbc6>] __lock_acquire+0x9e8/0xb93
   [<c012fdd9>] lock_acquire+0x68/0x82
   [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
   [<c0123109>] __queue_work+0x12/0x33
   [<c0123152>] queue_work+0x28/0x33
   [<c0123315>] queue_delayed_work+0xf/0x22
   [<c012333c>] schedule_delayed_work+0x14/0x16
   [<c025c1cb>] linkwatch_fire_event+0xa9/0xae
   [<c02605e3>] netif_carrier_off+0x1a/0x1c
   [<d886a650>] _sc92031_reset+0x1a5/0x1dd [sc92031]
   [<d886b730>] sc92031_open+0xd3/0x16f [sc92031]
   [<c02549e7>] dev_open+0x33/0x6e
   [<c025337f>] dev_change_flags+0x57/0x10b
   [<c028b237>] devinet_ioctl+0x235/0x546
   [<c028b837>] inet_ioctl+0x89/0xaa
   [<c0249cd1>] sock_ioctl+0x1ac/0x1ca
   [<c0170a70>] do_ioctl+0x1c/0x53
   [<c0170c93>] vfs_ioctl+0x1ec/0x203
   [<c0170cf3>] sys_ioctl+0x49/0x62
   [<c0103ca8>] sysenter_past_esp+0x5d/0x99
   [<ffffffff>] 0xffffffff

 -> (ratelimit_lock){....} ops: 1 {
    initial-use  at:
                          [<c012f664>] __lock_acquire+0x486/0xb93
                          [<c012fdd9>] lock_acquire+0x68/0x82
                          [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
                          [<c0116ec8>] __printk_ratelimit+0x1d/0xa5
                          [<c0116f66>] printk_ratelimit+0x16/0x18
                          [<d886a489>] _sc92031_check_media+0x160/0x182
[sc92031]
                          [<d886a660>] _sc92031_reset+0x1b5/0x1dd
[sc92031]
                          [<d886b730>] sc92031_open+0xd3/0x16f [sc92031]
                          [<c02549e7>] dev_open+0x33/0x6e
                          [<c025337f>] dev_change_flags+0x57/0x10b
                          [<c028b237>] devinet_ioctl+0x235/0x546
                          [<c028b837>] inet_ioctl+0x89/0xaa
                          [<c0249cd1>] sock_ioctl+0x1ac/0x1ca
                          [<c0170a70>] do_ioctl+0x1c/0x53
                          [<c0170c93>] vfs_ioctl+0x1ec/0x203
                          [<c0170cf3>] sys_ioctl+0x49/0x62
                          [<c0103ca8>] sysenter_past_esp+0x5d/0x99
                          [<ffffffff>] 0xffffffff
  }
  ... key      at: [<c03620dc>] ratelimit_lock.21472+0x1c/0x28
 ... acquired at:
   [<c012fbc6>] __lock_acquire+0x9e8/0xb93
   [<c012fdd9>] lock_acquire+0x68/0x82
   [<c02ab22b>] _spin_lock_irqsave+0x34/0x44
   [<c0116ec8>] __printk_ratelimit+0x1d/0xa5
   [<c0116f66>] printk_ratelimit+0x16/0x18
   [<d886a489>] _sc92031_check_media+0x160/0x182 [sc92031]
   [<d886a660>] _sc92031_reset+0x1b5/0x1dd [sc92031]
   [<d886b730>] sc92031_open+0xd3/0x16f [sc92031]
   [<c02549e7>] dev_open+0x33/0x6e
   [<c025337f>] dev_change_flags+0x57/0x10b
   [<c028b237>] devinet_ioctl+0x235/0x546
   [<c028b837>] inet_ioctl+0x89/0xaa
   [<c0249cd1>] sock_ioctl+0x1ac/0x1ca
   [<c0170a70>] do_ioctl+0x1c/0x53
   [<c0170c93>] vfs_ioctl+0x1ec/0x203
   [<c0170cf3>] sys_ioctl+0x49/0x62
   [<c0103ca8>] sysenter_past_esp+0x5d/0x99
   [<ffffffff>] 0xffffffff


stack backtrace:
 [<c010433c>] show_trace_log_lvl+0x1a/0x30
 [<c0104e92>] show_trace+0x12/0x14
 [<c0104eeb>] dump_stack+0x16/0x18
 [<c012f13b>] check_usage+0x25a/0x264
 [<c012fb28>] __lock_acquire+0x94a/0xb93
 [<c012fdd9>] lock_acquire+0x68/0x82
 [<c02aaf2a>] _spin_lock_bh+0x30/0x3d
 [<d886ad22>] sc92031_set_multicast_list+0x14/0x2d [sc92031]
 [<c025677e>] __dev_mc_upload+0x26/0x28
 [<c02568c4>] dev_mc_upload+0x25/0x3a
 [<c0254a02>] dev_open+0x4e/0x6e
 [<c025337f>] dev_change_flags+0x57/0x10b
 [<c028b237>] devinet_ioctl+0x235/0x546
 [<c028b837>] inet_ioctl+0x89/0xaa
 [<c0249cd1>] sock_ioctl+0x1ac/0x1ca
 [<c0170a70>] do_ioctl+0x1c/0x53
 [<c0170c93>] vfs_ioctl+0x1ec/0x203
 [<c0170cf3>] sys_ioctl+0x49/0x62
 [<c0103ca8>] sysenter_past_esp+0x5d/0x99
 =======================

