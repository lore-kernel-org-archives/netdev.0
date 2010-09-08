From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] lockdep warning in gen_kill_estimator
Date: Wed, 8 Sep 2010 11:27:19 -0700
Message-ID: <20100908112719.3f4b4644@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50541 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752673Ab0IHS11 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 14:27:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Saw big lockdep SOFTIRQ-unsafe lock warning in gen_kill_estimator when doing.

  tc qdisc del dev dummy0 root

Looks like this is new problem in 2.6.35 with the introduction of est_tree_lock.
Here is a patch that moves the bh disable to outside the loop.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---

[12075.878153] ======================================================
[12075.878157] [ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
[12075.878161] 2.6.36-rc3-next+ #30
[12075.878163] ------------------------------------------------------
[12075.878166] tc/17952 [HC0[0]:SC0[1]:HE1:SE0] is trying to acquire:
[12075.878169]  (est_tree_lock){+.+...}, at: [<ffffffff813eae72>] gen_estimator_active+0x22/0xb0
[12075.878180] 
[12075.878181] and this task is already holding:
[12075.878184]  (&(&list->lock)->rlock#5){+.-.-.}, at: [<ffffffff813ead44>] gnet_stats_start_copy_compat+0x44/0xb0
[12075.878192] which would create a new lock dependency:
[12075.878194]  (&(&list->lock)->rlock#5){+.-.-.} -> (est_tree_lock){+.+...}
[12075.878202] 
[12075.878203] but this new dependency connects a SOFTIRQ-irq-safe lock:
[12075.878205]  (&(&list->lock)->rlock#5){+.-.-.}
[12075.878209] ... which became SOFTIRQ-irq-safe at:
[12075.878211]   [<ffffffff81080d4f>] __lock_acquire+0x58f/0x1490
[12075.878218]   [<ffffffff81081ce3>] lock_acquire+0x93/0x130
[12075.878222]   [<ffffffff8149ba61>] _raw_spin_lock+0x31/0x70
[12075.878227]   [<ffffffff813f2f2c>] dev_queue_xmit+0xcc/0x6b0
[12075.878232]   [<ffffffff813fbf9e>] neigh_resolve_output+0x10e/0x3f0
[12075.878238]   [<ffffffffa0109df7>] ip6_finish_output2+0x107/0x3d0 [ipv6]
[12075.878252]   [<ffffffffa010a624>] ip6_finish_output+0x564/0xe50 [ipv6]
[12075.878261]   [<ffffffffa010af5b>] ip6_output+0x4b/0x190 [ipv6]
[12075.878270]   [<ffffffffa01267ee>] dst_output+0x1e/0x70 [ipv6]
[12075.878283]   [<ffffffffa0128178>] mld_sendpack+0x358/0x390 [ipv6]
[12075.878297]   [<ffffffffa0128a13>] mld_ifc_timer_expire+0x283/0x310 [ipv6]
[12075.878310]   [<ffffffff81059067>] run_timer_softirq+0x1d7/0x400
[12075.878315]   [<ffffffff81050712>] __do_softirq+0xc2/0x250
[12075.878320]   [<ffffffff8100358c>] call_softirq+0x1c/0x50
[12075.878325]   [<ffffffff81004f75>] do_softirq+0x75/0xb0
[12075.878329]   [<ffffffff8105034d>] irq_exit+0x8d/0xa0
[12075.878333]   [<ffffffff810044c0>] do_IRQ+0x70/0xf0
[12075.878337]   [<ffffffff8149c793>] ret_from_intr+0x0/0xf
[12075.878342]   [<ffffffff81222e9f>] avc_has_perm_noaudit+0x14f/0x4e0
[12075.878348]   [<ffffffff81223276>] avc_has_perm+0x46/0x90
[12075.878353]   [<ffffffff812242df>] inode_has_perm+0x4f/0x90
[12075.878357]   [<ffffffff812243f1>] file_has_perm+0xd1/0xe0
[12075.878361]   [<ffffffff81226eda>] selinux_file_permission+0xba/0x150
[12075.878366]   [<ffffffff812215ba>] security_file_permission+0x1a/0x70
[12075.878371]   [<ffffffff81120408>] rw_verify_area+0x58/0xc0
[12075.878376]   [<ffffffff8112069e>] vfs_read+0x9e/0x190
[12075.878381]   [<ffffffff81120e1f>] sys_read+0x4f/0x90
[12075.878385]   [<ffffffff8100266b>] system_call_fastpath+0x16/0x1b
[12075.878390] 
[12075.878391] to a SOFTIRQ-irq-unsafe lock:
[12075.878393]  (est_tree_lock){+.+...}
[12075.878396] ... which became SOFTIRQ-irq-unsafe at:
[12075.878398] ...  [<ffffffff81080db2>] __lock_acquire+0x5f2/0x1490
[12075.878404]   [<ffffffff81081ce3>] lock_acquire+0x93/0x130
[12075.878408]   [<ffffffff8149ba61>] _raw_spin_lock+0x31/0x70
[12075.878412]   [<ffffffff813eaf1f>] gen_kill_estimator+0x1f/0xe0
[12075.878417]   [<ffffffff814079a6>] qdisc_destroy+0x56/0xb0
[12075.878422]   [<ffffffff81407dd1>] dev_shutdown+0x71/0xa0
[12075.878426]   [<ffffffff813ee8b8>] rollback_registered_many+0x1a8/0x310
[12075.878432]   [<ffffffff813eeb36>] unregister_netdevice_queue+0x96/0xf0
[12075.878437]   [<ffffffff813eebab>] unregister_netdev+0x1b/0x30
[12075.878442]   [<ffffffff81378a8e>] ppp_shutdown_interface+0x15e/0x170
[12075.878447]   [<ffffffff81378b01>] ppp_release+0x61/0xa0
[12075.878452]   [<ffffffff81122296>] fput+0xf6/0x260
[12075.878456]   [<ffffffff8111e8a8>] filp_close+0x58/0x90
[12075.878461]   [<ffffffff8111e994>] sys_close+0xb4/0x120
[12075.878466]   [<ffffffff8100266b>] system_call_fastpath+0x16/0x1b
[12075.878471] 
[12075.878472] other info that might help us debug this:
[12075.878473] 
[12075.878476] 3 locks held by tc/17952:
[12075.878478]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8141069b>] netlink_dump+0x4b/0x200
[12075.878486]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff8140a900>] tc_dump_qdisc+0x0/0x120
[12075.878495]  #2:  (&(&list->lock)->rlock#5){+.-.-.}, at: [<ffffffff813ead44>] gnet_stats_start_copy_compat+0x44/0xb0
[12075.878504] 
[12075.878505] the dependencies between SOFTIRQ-irq-safe lock and the holding lock:
[12075.878519] -> (&(&list->lock)->rlock#5){+.-.-.} ops: 678027 {
[12075.878526]    HARDIRQ-ON-W at:
[12075.878529]                                        [<ffffffff81080d7e>] __lock_acquire+0x5be/0x1490
[12075.878534]                                        [<ffffffff81081ce3>] lock_acquire+0x93/0x130
[12075.878539]                                        [<ffffffff8149ba61>] _raw_spin_lock+0x31/0x70
[12075.878544]                                        [<ffffffff813f2f2c>] dev_queue_xmit+0xcc/0x6b0
[12075.878549]                                        [<ffffffff813fbf9e>] neigh_resolve_output+0x10e/0x3f0
[12075.878554]                                        [<ffffffffa0109df7>] ip6_finish_output2+0x107/0x3d0 [ipv6]
[12075.878565]                                        [<ffffffffa010a624>] ip6_finish_output+0x564/0xe50 [ipv6]
[12075.878575]                                        [<ffffffffa010af5b>] ip6_output+0x4b/0x190 [ipv6]
[12075.878584]                                        [<ffffffffa01267ee>] dst_output+0x1e/0x70 [ipv6]
[12075.878597]                                        [<ffffffffa0128178>] mld_sendpack+0x358/0x390 [ipv6]
[12075.878611]                                        [<ffffffffa0128a13>] mld_ifc_timer_expire+0x283/0x310 [ipv6]
[12075.878625]                                        [<ffffffff81059067>] run_timer_softirq+0x1d7/0x400
[12075.878630]                                        [<ffffffff81050712>] __do_softirq+0xc2/0x250
[12075.878635]                                        [<ffffffff8100358c>] call_softirq+0x1c/0x50
[12075.878640]                                        [<ffffffff81004f75>] do_softirq+0x75/0xb0
[12075.878645]                                        [<ffffffff8105034d>] irq_exit+0x8d/0xa0
[12075.878649]                                        [<ffffffff810044c0>] do_IRQ+0x70/0xf0
[12075.878654]                                        [<ffffffff8149c793>] ret_from_intr+0x0/0xf
[12075.878659]                                        [<ffffffff81222e9f>] avc_has_perm_noaudit+0x14f/0x4e0
[12075.878665]                                        [<ffffffff81223276>] avc_has_perm+0x46/0x90
[12075.878670]                                        [<ffffffff812242df>] inode_has_perm+0x4f/0x90
[12075.878675]                                        [<ffffffff812243f1>] file_has_perm+0xd1/0xe0
[12075.878679]                                        [<ffffffff81226eda>] selinux_file_permission+0xba/0x150
[12075.878684]                                        [<ffffffff812215ba>] security_file_permission+0x1a/0x70
[12075.878690]                                        [<ffffffff81120408>] rw_verify_area+0x58/0xc0
[12075.878695]                                        [<ffffffff8112069e>] vfs_read+0x9e/0x190
[12075.878700]                                        [<ffffffff81120e1f>] sys_read+0x4f/0x90
[12075.878705]                                        [<ffffffff8100266b>] system_call_fastpath+0x16/0x1b
[12075.878711]    IN-SOFTIRQ-W at:
[12075.878714]                                        [<ffffffff81080d4f>] __lock_acquire+0x58f/0x1490
[12075.878719]                                        [<ffffffff81081ce3>] lock_acquire+0x93/0x130
[12075.878724]                                        [<ffffffff8149ba61>] _raw_spin_lock+0x31/0x70
[12075.878728]                                        [<ffffffff813f2f2c>] dev_queue_xmit+0xcc/0x6b0
[12075.878733]                                        [<ffffffff813fbf9e>] neigh_resolve_output+0x10e/0x3f0
[12075.878738]                                        [<ffffffffa0109df7>] ip6_finish_output2+0x107/0x3d0 [ipv6]
[12075.878749]                                        [<ffffffffa010a624>] ip6_finish_output+0x564/0xe50 [ipv6]
[12075.878759]                                        [<ffffffffa010af5b>] ip6_output+0x4b/0x190 [ipv6]
[12075.878768]                                        [<ffffffffa01267ee>] dst_output+0x1e/0x70 [ipv6]
[12075.878782]                                        [<ffffffffa0128178>] mld_sendpack+0x358/0x390 [ipv6]
[12075.878795]                                        [<ffffffffa0128a13>] mld_ifc_timer_expire+0x283/0x310 [ipv6]
[12075.878809]                                        [<ffffffff81059067>] run_timer_softirq+0x1d7/0x400
[12075.878814]                                        [<ffffffff81050712>] __do_softirq+0xc2/0x250
[12075.878819]                                        [<ffffffff8100358c>] call_softirq+0x1c/0x50
[12075.878824]                                        [<ffffffff81004f75>] do_softirq+0x75/0xb0
[12075.878828]                                        [<ffffffff8105034d>] irq_exit+0x8d/0xa0
[12075.878833]                                        [<ffffffff810044c0>] do_IRQ+0x70/0xf0
[12075.878838]                                        [<ffffffff8149c793>] ret_from_intr+0x0/0xf
[12075.878842]                                        [<ffffffff81222e9f>] avc_has_perm_noaudit+0x14f/0x4e0
[12075.878848]                                        [<ffffffff81223276>] avc_has_perm+0x46/0x90
[12075.878853]                                        [<ffffffff812242df>] inode_has_perm+0x4f/0x90
[12075.878858]                                        [<ffffffff812243f1>] file_has_perm+0xd1/0xe0
[12075.878863]                                        [<ffffffff81226eda>] selinux_file_permission+0xba/0x150
[12075.878868]                                        [<ffffffff812215ba>] security_file_permission+0x1a/0x70
[12075.878873]                                        [<ffffffff81120408>] rw_verify_area+0x58/0xc0
[12075.878878]                                        [<ffffffff8112069e>] vfs_read+0x9e/0x190
[12075.878883]                                        [<ffffffff81120e1f>] sys_read+0x4f/0x90
[12075.878888]                                        [<ffffffff8100266b>] system_call_fastpath+0x16/0x1b
[12075.878894]    IN-RECLAIM_FS-W at:
[12075.878897]                                           [<ffffffff81080c03>] __lock_acquire+0x443/0x1490
[12075.878902]                                           [<ffffffff81081ce3>] lock_acquire+0x93/0x130
[12075.878907]                                           [<ffffffff8149ba61>] _raw_spin_lock+0x31/0x70
[12075.878912]                                           [<ffffffff813f2f2c>] dev_queue_xmit+0xcc/0x6b0
[12075.878917]                                           [<ffffffff814236bc>] ip_finish_output+0x1ac/0x4b0
[12075.878922]                                           [<ffffffff81423a61>] ip_output+0xa1/0x100
[12075.878926]                                           [<ffffffff81421cb8>] ip_local_out+0x28/0x80
[12075.878931]                                           [<ffffffff8142259d>] ip_queue_xmit+0x1bd/0x4f0
[12075.878936]                                           [<ffffffff81438800>] tcp_transmit_skb+0x3f0/0x890
[12075.878942]                                           [<ffffffff8143a428>] tcp_send_ack+0xd8/0x120
[12075.878947]                                           [<ffffffff8143bffa>] tcp_delack_timer+0x12a/0x220
[12075.878953]                                           [<ffffffff81059067>] run_timer_softirq+0x1d7/0x400
[12075.878958]                                           [<ffffffff81050712>] __do_softirq+0xc2/0x250
[12075.878963]                                           [<ffffffff8100358c>] call_softirq+0x1c/0x50
[12075.878967]                                           [<ffffffff81004f75>] do_softirq+0x75/0xb0
[12075.878972]                                           [<ffffffff8105034d>] irq_exit+0x8d/0xa0
[12075.878977]                                           [<ffffffff810200eb>] smp_apic_timer_interrupt+0x6b/0xa0
[12075.878983]                                           [<ffffffff81003053>] apic_timer_interrupt+0x13/0x20
[12075.878989]                                           [<ffffffff8149ba61>] _raw_spin_lock+0x31/0x70
[12075.878993]                                           [<ffffffff81133b3e>] __shrink_dcache_sb+0x13e/0x410
[12075.878999]                                           [<ffffffff81133f96>] shrink_dcache_memory+0x176/0x200
[12075.879004]                                           [<ffffffff810e6137>] shrink_slab+0x127/0x190
[12075.879009]                                           [<ffffffff810e7cdf>] balance_pgdat+0x2cf/0x590
[12075.879015]                                           [<ffffffff810e80d5>] kswapd+0x135/0x3e0
[12075.879020]                                           [<ffffffff8106a836>] kthread+0xb6/0xc0
[12075.879025]                                           [<ffffffff81003494>] kernel_thread_helper+0x4/0x10
[12075.879030]    INITIAL USE at:
[12075.879033]                                       [<ffffffff810809eb>] __lock_acquire+0x22b/0x1490
[12075.879038]                                       [<ffffffff81081ce3>] lock_acquire+0x93/0x130
[12075.879043]                                       [<ffffffff8149ba61>] _raw_spin_lock+0x31/0x70
[12075.879047]                                       [<ffffffff813f2f2c>] dev_queue_xmit+0xcc/0x6b0
[12075.879052]                                       [<ffffffff813fbf9e>] neigh_resolve_output+0x10e/0x3f0
[12075.879058]                                       [<ffffffffa0109df7>] ip6_finish_output2+0x107/0x3d0 [ipv6]
[12075.879068]                                       [<ffffffffa010a624>] ip6_finish_output+0x564/0xe50 [ipv6]
[12075.879078]                                       [<ffffffffa010af5b>] ip6_output+0x4b/0x190 [ipv6]
[12075.879087]                                       [<ffffffffa01267ee>] dst_output+0x1e/0x70 [ipv6]
[12075.879101]                                       [<ffffffffa0128178>] mld_sendpack+0x358/0x390 [ipv6]
[12075.879114]                                       [<ffffffffa0128a13>] mld_ifc_timer_expire+0x283/0x310 [ipv6]
[12075.879128]                                       [<ffffffff81059067>] run_timer_softirq+0x1d7/0x400
[12075.879133]                                       [<ffffffff81050712>] __do_softirq+0xc2/0x250
[12075.879138]                                       [<ffffffff8100358c>] call_softirq+0x1c/0x50
[12075.879143]                                       [<ffffffff81004f75>] do_softirq+0x75/0xb0
[12075.879147]                                       [<ffffffff8105034d>] irq_exit+0x8d/0xa0
[12075.879152]                                       [<ffffffff810044c0>] do_IRQ+0x70/0xf0
[12075.879156]                                       [<ffffffff8149c793>] ret_from_intr+0x0/0xf
[12075.879161]                                       [<ffffffff81222e9f>] avc_has_perm_noaudit+0x14f/0x4e0
[12075.879167]                                       [<ffffffff81223276>] avc_has_perm+0x46/0x90
[12075.879172]                                       [<ffffffff812242df>] inode_has_perm+0x4f/0x90
[12075.879177]                                       [<ffffffff812243f1>] file_has_perm+0xd1/0xe0
[12075.879182]                                       [<ffffffff81226eda>] selinux_file_permission+0xba/0x150
[12075.879187]                                       [<ffffffff812215ba>] security_file_permission+0x1a/0x70
[12075.879192]                                       [<ffffffff81120408>] rw_verify_area+0x58/0xc0
[12075.879198]                                       [<ffffffff8112069e>] vfs_read+0x9e/0x190
[12075.879203]                                       [<ffffffff81120e1f>] sys_read+0x4f/0x90
[12075.879208]                                       [<ffffffff8100266b>] system_call_fastpath+0x16/0x1b
[12075.879213]  }
[12075.879215]  ... key      at: [<ffffffff8264dd40>] __key.26712+0x0/0x8
[12075.879221]  ... acquired at:
[12075.879223]    [<ffffffff8107fbd0>] check_irq_usage+0x60/0xf0
[12075.879228]    [<ffffffff81081451>] __lock_acquire+0xc91/0x1490
[12075.879232]    [<ffffffff81081ce3>] lock_acquire+0x93/0x130
[12075.879237]    [<ffffffff8149ba61>] _raw_spin_lock+0x31/0x70
[12075.879241]    [<ffffffff813eae72>] gen_estimator_active+0x22/0xb0
[12075.879246]    [<ffffffff813eaded>] gnet_stats_copy_rate_est+0x1d/0x80
[12075.879251]    [<ffffffff8140a741>] tc_fill_qdisc+0x2c1/0x360
[12075.879256]    [<ffffffff8140a8e8>] tc_dump_qdisc_root+0x108/0x120
[12075.879261]    [<ffffffff8140a998>] tc_dump_qdisc+0x98/0x120
[12075.879265]    [<ffffffff814106b5>] netlink_dump+0x65/0x200
[12075.879270]    [<ffffffff81412885>] netlink_dump_start+0x195/0x220
[12075.879274]    [<ffffffff813fdc12>] rtnetlink_rcv_msg+0x232/0x270
[12075.879280]    [<ffffffff814126c1>] netlink_rcv_skb+0xa1/0xd0
[12075.879284]    [<ffffffff813fd9d0>] rtnetlink_rcv+0x20/0x30
[12075.879288]    [<ffffffff814122f6>] netlink_unicast+0x296/0x2e0
[12075.879293]    [<ffffffff81413120>] netlink_sendmsg+0x250/0x360
[12075.879297]    [<ffffffff813dd4ae>] sock_sendmsg+0xee/0x120
[12075.879302]    [<ffffffff813dddc0>] sys_sendmsg+0x230/0x390
[12075.879307]    [<ffffffff8100266b>] system_call_fastpath+0x16/0x1b
[12075.879311] 
[12075.879313] 
[12075.879314] the dependencies between the lock to be acquired and SOFTIRQ-irq-unsafe lock:
[12075.879326] -> (est_tree_lock){+.+...} ops: 7 {
[12075.879332]    HARDIRQ-ON-W at:
[12075.879335]                                        [<ffffffff81080d7e>] __lock_acquire+0x5be/0x1490
[12075.879340]                                        [<ffffffff81081ce3>] lock_acquire+0x93/0x130
[12075.879345]                                        [<ffffffff8149ba61>] _raw_spin_lock+0x31/0x70
[12075.879350]                                        [<ffffffff813eaf1f>] gen_kill_estimator+0x1f/0xe0
[12075.879355]                                        [<ffffffff814079a6>] qdisc_destroy+0x56/0xb0
[12075.879360]                                        [<ffffffff81407dd1>] dev_shutdown+0x71/0xa0
[12075.879365]                                        [<ffffffff813ee8b8>] rollback_registered_many+0x1a8/0x310
[12075.879371]                                        [<ffffffff813eeb36>] unregister_netdevice_queue+0x96/0xf0
[12075.879376]                                        [<ffffffff813eebab>] unregister_netdev+0x1b/0x30
[12075.879382]                                        [<ffffffff81378a8e>] ppp_shutdown_interface+0x15e/0x170
[12075.879387]                                        [<ffffffff81378b01>] ppp_release+0x61/0xa0
[12075.879392]                                        [<ffffffff81122296>] fput+0xf6/0x260
[12075.879397]                                        [<ffffffff8111e8a8>] filp_close+0x58/0x90
[12075.879402]                                        [<ffffffff8111e994>] sys_close+0xb4/0x120
[12075.879407]                                        [<ffffffff8100266b>] system_call_fastpath+0x16/0x1b
[12075.879412]    SOFTIRQ-ON-W at:
[12075.879415]                                        [<ffffffff81080db2>] __lock_acquire+0x5f2/0x1490
[12075.879420]                                        [<ffffffff81081ce3>] lock_acquire+0x93/0x130
[12075.879425]                                        [<ffffffff8149ba61>] _raw_spin_lock+0x31/0x70
[12075.879430]                                        [<ffffffff813eaf1f>] gen_kill_estimator+0x1f/0xe0
[12075.879435]                                        [<ffffffff814079a6>] qdisc_destroy+0x56/0xb0
[12075.879440]                                        [<ffffffff81407dd1>] dev_shutdown+0x71/0xa0
[12075.879445]                                        [<ffffffff813ee8b8>] rollback_registered_many+0x1a8/0x310
[12075.879451]                                        [<ffffffff813eeb36>] unregister_netdevice_queue+0x96/0xf0
[12075.879457]                                        [<ffffffff813eebab>] unregister_netdev+0x1b/0x30
[12075.879462]                                        [<ffffffff81378a8e>] ppp_shutdown_interface+0x15e/0x170
[12075.879467]                                        [<ffffffff81378b01>] ppp_release+0x61/0xa0
[12075.879472]                                        [<ffffffff81122296>] fput+0xf6/0x260
[12075.879477]                                        [<ffffffff8111e8a8>] filp_close+0x58/0x90
[12075.879482]                                        [<ffffffff8111e994>] sys_close+0xb4/0x120
[12075.879487]                                        [<ffffffff8100266b>] system_call_fastpath+0x16/0x1b
[12075.879493]    INITIAL USE at:
[12075.879496]                                       [<ffffffff810809eb>] __lock_acquire+0x22b/0x1490
[12075.879501]                                       [<ffffffff81081ce3>] lock_acquire+0x93/0x130
[12075.879506]                                       [<ffffffff8149ba61>] _raw_spin_lock+0x31/0x70
[12075.879511]                                       [<ffffffff813eaf1f>] gen_kill_estimator+0x1f/0xe0
[12075.879517]                                       [<ffffffff814079a6>] qdisc_destroy+0x56/0xb0
[12075.879522]                                       [<ffffffff81407dd1>] dev_shutdown+0x71/0xa0
[12075.879527]                                       [<ffffffff813ee8b8>] rollback_registered_many+0x1a8/0x310
[12075.879533]                                       [<ffffffff813eeb36>] unregister_netdevice_queue+0x96/0xf0
[12075.879539]                                       [<ffffffff813eebab>] unregister_netdev+0x1b/0x30
[12075.879545]                                       [<ffffffff81378a8e>] ppp_shutdown_interface+0x15e/0x170
[12075.879551]                                       [<ffffffff81378b01>] ppp_release+0x61/0xa0
[12075.879556]                                       [<ffffffff81122296>] fput+0xf6/0x260
[12075.879561]                                       [<ffffffff8111e8a8>] filp_close+0x58/0x90
[12075.879567]                                       [<ffffffff8111e994>] sys_close+0xb4/0x120
[12075.879572]                                       [<ffffffff8100266b>] system_call_fastpath+0x16/0x1b
[12075.879578]  }
[12075.879579]  ... key      at: [<ffffffff81a66a78>] est_tree_lock+0x18/0x40
[12075.879585]  ... acquired at:
[12075.879586]    [<ffffffff8107fbd0>] check_irq_usage+0x60/0xf0
[12075.879591]    [<ffffffff81081451>] __lock_acquire+0xc91/0x1490
[12075.879596]    [<ffffffff81081ce3>] lock_acquire+0x93/0x130
[12075.879600]    [<ffffffff8149ba61>] _raw_spin_lock+0x31/0x70
[12075.879605]    [<ffffffff813eae72>] gen_estimator_active+0x22/0xb0
[12075.879610]    [<ffffffff813eaded>] gnet_stats_copy_rate_est+0x1d/0x80
[12075.879615]    [<ffffffff8140a741>] tc_fill_qdisc+0x2c1/0x360
[12075.879620]    [<ffffffff8140a8e8>] tc_dump_qdisc_root+0x108/0x120
[12075.879625]    [<ffffffff8140a998>] tc_dump_qdisc+0x98/0x120
[12075.879629]    [<ffffffff814106b5>] netlink_dump+0x65/0x200
[12075.879634]    [<ffffffff81412885>] netlink_dump_start+0x195/0x220
[12075.879638]    [<ffffffff813fdc12>] rtnetlink_rcv_msg+0x232/0x270
[12075.879643]    [<ffffffff814126c1>] netlink_rcv_skb+0xa1/0xd0
[12075.879647]    [<ffffffff813fd9d0>] rtnetlink_rcv+0x20/0x30
[12075.879652]    [<ffffffff814122f6>] netlink_unicast+0x296/0x2e0
[12075.879656]    [<ffffffff81413120>] netlink_sendmsg+0x250/0x360
[12075.879660]    [<ffffffff813dd4ae>] sock_sendmsg+0xee/0x120
[12075.879665]    [<ffffffff813dddc0>] sys_sendmsg+0x230/0x390
[12075.879670]    [<ffffffff8100266b>] system_call_fastpath+0x16/0x1b
[12075.879674] 
[12075.879676] 
[12075.879677] stack backtrace:
[12075.879680] Pid: 17952, comm: tc Not tainted 2.6.36-rc3-next+ #30
[12075.879683] Call Trace:
[12075.879687]  [<ffffffff8107fb60>] check_usage+0x480/0x490
[12075.879693]  [<ffffffff8107fbd0>] check_irq_usage+0x60/0xf0
[12075.879697]  [<ffffffff81081451>] __lock_acquire+0xc91/0x1490
[12075.879702]  [<ffffffff81081ce3>] lock_acquire+0x93/0x130
[12075.879706]  [<ffffffff813eae72>] ? gen_estimator_active+0x22/0xb0
[12075.879711]  [<ffffffff812718e3>] ? __nla_reserve+0x53/0x70
[12075.879715]  [<ffffffff8149ba61>] _raw_spin_lock+0x31/0x70
[12075.879720]  [<ffffffff813eae72>] ? gen_estimator_active+0x22/0xb0
[12075.879724]  [<ffffffff8127192a>] ? __nla_put+0x2a/0x40
[12075.879728]  [<ffffffff813eae72>] gen_estimator_active+0x22/0xb0
[12075.879733]  [<ffffffff813eaded>] gnet_stats_copy_rate_est+0x1d/0x80
[12075.879738]  [<ffffffff8140a741>] tc_fill_qdisc+0x2c1/0x360
[12075.879743]  [<ffffffff8140a8e8>] tc_dump_qdisc_root+0x108/0x120
[12075.879748]  [<ffffffff8149a57d>] ? __mutex_lock_common+0x27d/0x3a0
[12075.879752]  [<ffffffff8141069b>] ? netlink_dump+0x4b/0x200
[12075.879757]  [<ffffffff8140a998>] tc_dump_qdisc+0x98/0x120
[12075.879761]  [<ffffffff8140a900>] ? tc_dump_qdisc+0x0/0x120
[12075.879765]  [<ffffffff814106b5>] netlink_dump+0x65/0x200
[12075.879770]  [<ffffffff8108056d>] ? trace_hardirqs_on+0xd/0x10
[12075.879774]  [<ffffffff81412885>] netlink_dump_start+0x195/0x220
[12075.879779]  [<ffffffff8140a900>] ? tc_dump_qdisc+0x0/0x120
[12075.879783]  [<ffffffff813fdc12>] rtnetlink_rcv_msg+0x232/0x270
[12075.879788]  [<ffffffff813fd9e0>] ? rtnetlink_rcv_msg+0x0/0x270
[12075.879792]  [<ffffffff814126c1>] netlink_rcv_skb+0xa1/0xd0
[12075.879797]  [<ffffffff813fd9d0>] rtnetlink_rcv+0x20/0x30
[12075.879801]  [<ffffffff814122f6>] netlink_unicast+0x296/0x2e0
[12075.879805]  [<ffffffff81413120>] netlink_sendmsg+0x250/0x360
[12075.879810]  [<ffffffff813dd4ae>] sock_sendmsg+0xee/0x120
[12075.879815]  [<ffffffff810f2f77>] ? might_fault+0x57/0xb0
[12075.879819]  [<ffffffff810f2f77>] ? might_fault+0x57/0xb0
[12075.879823]  [<ffffffff810f2fc0>] ? might_fault+0xa0/0xb0
[12075.879827]  [<ffffffff810f2f77>] ? might_fault+0x57/0xb0
[12075.879831]  [<ffffffff813dbd1d>] ? move_addr_to_kernel+0x5d/0x60
[12075.879836]  [<ffffffff813e82e0>] ? verify_iovec+0x80/0xe0
[12075.879840]  [<ffffffff813dddc0>] sys_sendmsg+0x230/0x390
[12075.879846]  [<ffffffff810715bd>] ? sched_clock_cpu+0xcd/0x110
[12075.879850]  [<ffffffff8107c80d>] ? trace_hardirqs_off+0xd/0x10
[12075.879854]  [<ffffffff8106fd4e>] ? up_read+0x1e/0x40
[12075.879860]  [<ffffffff810a6c8c>] ? audit_syscall_entry+0x24c/0x270
[12075.879865]  [<ffffffff81080515>] ? trace_hardirqs_on_caller+0x145/0x190
[12075.879869]  [<ffffffff8149b7c9>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[12075.879874]  [<ffffffff8100266b>] system_call_fastpath+0x16/0x1b


--- a/net/core/gen_estimator.c	2010-09-08 11:16:10.184368926 -0700
+++ b/net/core/gen_estimator.c	2010-09-08 11:16:24.694194050 -0700
@@ -270,18 +270,18 @@ void gen_kill_estimator(struct gnet_stat
 {
 	struct gen_estimator *e;
 
-	spin_lock(&est_tree_lock);
+	spin_lock_bh(&est_tree_lock);
 	while ((e = gen_find_node(bstats, rate_est))) {
 		rb_erase(&e->node, &est_root);
 
-		write_lock_bh(&est_lock);
+		write_lock(&est_lock);
 		e->bstats = NULL;
-		write_unlock_bh(&est_lock);
+		write_unlock(&est_lock);
 
 		list_del_rcu(&e->list);
 		call_rcu(&e->e_rcu, __gen_kill_estimator);
 	}
-	spin_unlock(&est_tree_lock);
+	spin_unlock_bh(&est_tree_lock);
 }
 EXPORT_SYMBOL(gen_kill_estimator);
 
