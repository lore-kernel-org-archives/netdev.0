From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Fix lockdep warning on est_tree_lock in
 gen_estimator
Date: Thu, 2 Sep 2010 22:12:58 +0200
Message-ID: <20100902201257.GA3089@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50676 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756770Ab0IBUNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 16:13:06 -0400
Received: by wyb35 with SMTP id 35so110073wyb.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 13:13:04 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Almost any tc qdisc activity on 2.6.35 or later triggers this warning
(the patch below):

[  516.287584] =========================================================
[  516.288386] [ INFO: possible irq lock inversion dependency detected ]
[  516.288386] 2.6.35b #7
[  516.288386] ---------------------------------------------------------
[  516.288386] swapper/0 just changed the state of lock:
[  516.288386]  (&qdisc_tx_lock){+.-...}, at: [<c12eacda>] est_timer+0x62/0x1b4
[  516.288386] but this lock took another, SOFTIRQ-unsafe lock in the past:
[  516.288386]  (est_tree_lock){+.+...}
[  516.288386] 
[  516.288386] and interrupts could create inverse lock ordering between them.
[  516.288386] 
[  516.288386] 
[  516.288386] other info that might help us debug this:
[  516.288386] 2 locks held by swapper/0:
[  516.288386]  #0:  (&elist[idx].timer){+.-...}, at: [<c10334b5>] run_timer_softirq+0x11d/0x263
[  516.288386]  #1:  (rcu_read_lock){.+.+..}, at: [<c12eac78>] est_timer+0x0/0x1b4
[  516.288386] 
[  516.288386] the shortest dependencies between 2nd lock and 1st lock:
[  516.288386]  -> (est_tree_lock){+.+...} ops: 5 {
[  516.288386]     HARDIRQ-ON-W at:
[  516.288386]                                          [<c104a421>] __lock_acquire+0x306/0xbd6
[  516.288386]                                          [<c104ad9d>] lock_acquire+0xac/0xc8
[  516.288386]                                          [<c13c53ce>] _raw_spin_lock+0x25/0x34
[  516.288386]                                          [<c12ea985>] gen_estimator_active+0x39/0x74
[  516.288386]                                          [<c12ea82a>] gnet_stats_copy_rate_est+0x16/0x4d
[  516.288386]                                          [<c1300000>] tc_fill_qdisc+0x186/0x1e2
[  516.288386]                                          [<c13001b2>] qdisc_notify+0x94/0xcf
[  516.288386]                                          [<c1300385>] notify_and_destroy+0x27/0x3d
[  516.288386]                                          [<c1300490>] qdisc_graft+0xf5/0x1c6
[  516.288386]                                          [<c130110a>] tc_modify_qdisc+0x369/0x3b8
[  516.288386]                                          [<c12f8d09>] rtnetlink_rcv_msg+0x197/0x1b1
[  516.288386]                                          [<c1305cc0>] netlink_rcv_skb+0x30/0x75
[  516.288386]                                          [<c12f8b6a>] rtnetlink_rcv+0x1e/0x26
[  516.288386]                                          [<c1305b01>] netlink_unicast+0xc4/0x11a
[  516.288386]                                          [<c13061a2>] netlink_sendmsg+0x23a/0x252
[  516.288386]                                          [<c12e09fd>] __sock_sendmsg+0x4d/0x56
[  516.288386]                                          [<c12e0e42>] sock_sendmsg+0x95/0xab
[  516.288386]                                          [<c12e1024>] sys_sendmsg+0x13f/0x18f
[  516.288386]                                          [<c12e2676>] sys_socketcall+0x155/0x1a3
[  516.288386]                                          [<c13c5e25>] syscall_call+0x7/0xb
[  516.288386]     SOFTIRQ-ON-W at:
[  516.288386]                                          [<c104a442>] __lock_acquire+0x327/0xbd6
[  516.288386]                                          [<c104ad9d>] lock_acquire+0xac/0xc8
[  516.288386]                                          [<c13c53ce>] _raw_spin_lock+0x25/0x34
[  516.288386]                                          [<c12ea9d8>] gen_kill_estimator+0x18/0x9b
[  516.288386]                                          [<c12fea48>] qdisc_destroy+0x34/0x79
[  516.288386]                                          [<c1300393>] notify_and_destroy+0x35/0x3d
[  516.288386]                                          [<c1300490>] qdisc_graft+0xf5/0x1c6
[  516.288386]                                          [<c1300686>] tc_get_qdisc+0x125/0x157
[  516.288386]                                          [<c12f8d09>] rtnetlink_rcv_msg+0x197/0x1b1
[  516.288386]                                          [<c1305cc0>] netlink_rcv_skb+0x30/0x75
[  516.288386]                                          [<c12f8b6a>] rtnetlink_rcv+0x1e/0x26
[  516.288386]                                          [<c1305b01>] netlink_unicast+0xc4/0x11a
[  516.288386]                                          [<c13061a2>] netlink_sendmsg+0x23a/0x252
[  516.288386]                                          [<c12e09fd>] __sock_sendmsg+0x4d/0x56
[  516.288386]                                          [<c12e0e42>] sock_sendmsg+0x95/0xab
[  516.288386]                                          [<c12e1024>] sys_sendmsg+0x13f/0x18f
[  516.288386]                                          [<c12e2676>] sys_socketcall+0x155/0x1a3
[  516.288386]                                          [<c13c5e25>] syscall_call+0x7/0xb
[  516.288386]     INITIAL USE at:
[  516.288386]                                         [<c104a49a>] __lock_acquire+0x37f/0xbd6
[  516.288386]                                         [<c104ad9d>] lock_acquire+0xac/0xc8
[  516.288386]                                         [<c13c53ce>] _raw_spin_lock+0x25/0x34
[  516.288386]                                         [<c12ea985>] gen_estimator_active+0x39/0x74
[  516.288386]                                         [<c12ea82a>] gnet_stats_copy_rate_est+0x16/0x4d
[  516.288386]                                         [<c1300000>] tc_fill_qdisc+0x186/0x1e2
[  516.288386]                                         [<c13001b2>] qdisc_notify+0x94/0xcf
[  516.288386]                                         [<c1300385>] notify_and_destroy+0x27/0x3d
[  516.288386]                                         [<c1300490>] qdisc_graft+0xf5/0x1c6
[  516.288386]                                         [<c130110a>] tc_modify_qdisc+0x369/0x3b8
[  516.288386]                                         [<c12f8d09>] rtnetlink_rcv_msg+0x197/0x1b1
[  516.288386]                                         [<c1305cc0>] netlink_rcv_skb+0x30/0x75
[  516.288386]                                         [<c12f8b6a>] rtnetlink_rcv+0x1e/0x26
[  516.288386]                                         [<c1305b01>] netlink_unicast+0xc4/0x11a
[  516.288386]                                         [<c13061a2>] netlink_sendmsg+0x23a/0x252
[  516.288386]                                         [<c12e09fd>] __sock_sendmsg+0x4d/0x56
[  516.288386]                                         [<c12e0e42>] sock_sendmsg+0x95/0xab
[  516.288386]                                         [<c12e1024>] sys_sendmsg+0x13f/0x18f
[  516.288386]                                         [<c12e2676>] sys_socketcall+0x155/0x1a3
[  516.288386]                                         [<c13c5e25>] syscall_call+0x7/0xb
[  516.288386]   }
[  516.288386]   ... key      at: [<c15a70fc>] est_tree_lock+0x10/0x1c
[  516.288386]   ... acquired at:
[  516.288386]    [<c104ad9d>] lock_acquire+0xac/0xc8
[  516.288386]    [<c13c53ce>] _raw_spin_lock+0x25/0x34
[  516.288386]    [<c12ea985>] gen_estimator_active+0x39/0x74
[  516.288386]    [<c12ea82a>] gnet_stats_copy_rate_est+0x16/0x4d
[  516.288386]    [<c1300000>] tc_fill_qdisc+0x186/0x1e2
[  516.288386]    [<c13001b2>] qdisc_notify+0x94/0xcf
[  516.288386]    [<c1300385>] notify_and_destroy+0x27/0x3d
[  516.288386]    [<c1300490>] qdisc_graft+0xf5/0x1c6
[  516.288386]    [<c130110a>] tc_modify_qdisc+0x369/0x3b8
[  516.288386]    [<c12f8d09>] rtnetlink_rcv_msg+0x197/0x1b1
[  516.288386]    [<c1305cc0>] netlink_rcv_skb+0x30/0x75
[  516.288386]    [<c12f8b6a>] rtnetlink_rcv+0x1e/0x26
[  516.288386]    [<c1305b01>] netlink_unicast+0xc4/0x11a
[  516.288386]    [<c13061a2>] netlink_sendmsg+0x23a/0x252
[  516.288386]    [<c12e09fd>] __sock_sendmsg+0x4d/0x56
[  516.288386]    [<c12e0e42>] sock_sendmsg+0x95/0xab
[  516.288386]    [<c12e1024>] sys_sendmsg+0x13f/0x18f
[  516.288386]    [<c12e2676>] sys_socketcall+0x155/0x1a3
[  516.288386]    [<c13c5e25>] syscall_call+0x7/0xb
[  516.288386] 
[  516.288386] -> (&qdisc_tx_lock){+.-...} ops: 10 {
[  516.288386]    HARDIRQ-ON-W at:
[  516.288386]                                        [<c104a421>] __lock_acquire+0x306/0xbd6
[  516.288386]                                        [<c104ad9d>] lock_acquire+0xac/0xc8
[  516.288386]                                        [<c13c55e1>] _raw_spin_lock_bh+0x2a/0x39
[  516.288386]                                        [<c12ea8f1>] gnet_stats_start_copy_compat+0x27/0x70
[  516.288386]                                        [<c12fffc7>] tc_fill_qdisc+0x14d/0x1e2
[  516.288386]                                        [<c13001b2>] qdisc_notify+0x94/0xcf
[  516.288386]                                        [<c1300385>] notify_and_destroy+0x27/0x3d
[  516.288386]                                        [<c1300490>] qdisc_graft+0xf5/0x1c6
[  516.288386]                                        [<c130110a>] tc_modify_qdisc+0x369/0x3b8
[  516.288386]                                        [<c12f8d09>] rtnetlink_rcv_msg+0x197/0x1b1
[  516.288386]                                        [<c1305cc0>] netlink_rcv_skb+0x30/0x75
[  516.288386]                                        [<c12f8b6a>] rtnetlink_rcv+0x1e/0x26
[  516.288386]                                        [<c1305b01>] netlink_unicast+0xc4/0x11a
[  516.288386]                                        [<c13061a2>] netlink_sendmsg+0x23a/0x252
[  516.288386]                                        [<c12e09fd>] __sock_sendmsg+0x4d/0x56
[  516.288386]                                        [<c12e0e42>] sock_sendmsg+0x95/0xab
[  516.288386]                                        [<c12e1024>] sys_sendmsg+0x13f/0x18f
[  516.288386]                                        [<c12e2676>] sys_socketcall+0x155/0x1a3
[  516.288386]                                        [<c13c5e25>] syscall_call+0x7/0xb
[  516.288386]    IN-SOFTIRQ-W at:
[  516.288386]                                        [<c104a3c3>] __lock_acquire+0x2a8/0xbd6
[  516.288386]                                        [<c104ad9d>] lock_acquire+0xac/0xc8
[  516.288386]                                        [<c13c53ce>] _raw_spin_lock+0x25/0x34
[  516.288386]                                        [<c12eacda>] est_timer+0x62/0x1b4
[  516.288386]                                        [<c1033536>] run_timer_softirq+0x19e/0x263
[  516.288386]                                        [<c102d692>] __do_softirq+0xab/0x169
[  516.288386]                                        [<c102d77a>] do_softirq+0x2a/0x42
[  516.288386]                                        [<c102d8d6>] irq_exit+0x36/0x42
[  516.288386]                                        [<c1014705>] smp_apic_timer_interrupt+0x66/0x71
[  516.288386]                                        [<c13c5fdf>] apic_timer_interrupt+0x2f/0x34
[  516.288386]                                        [<c1001c13>] cpu_idle+0x31/0x5a
[  516.288386]                                        [<c13bc316>] rest_init+0xda/0xdf
[  516.288386]                                        [<c15ba7c3>] start_kernel+0x2d4/0x2d9
[  516.288386]                                        [<c15ba09f>] i386_start_kernel+0x9f/0xa7
[  516.288386]    INITIAL USE at:
[  516.288386]                                       [<c104a49a>] __lock_acquire+0x37f/0xbd6
[  516.288386]                                       [<c104ad9d>] lock_acquire+0xac/0xc8
[  516.288386]                                       [<c13c55e1>] _raw_spin_lock_bh+0x2a/0x39
[  516.288386]                                       [<c12ea8f1>] gnet_stats_start_copy_compat+0x27/0x70
[  516.288386]                                       [<c12fffc7>] tc_fill_qdisc+0x14d/0x1e2
[  516.288386]                                       [<c13001b2>] qdisc_notify+0x94/0xcf
[  516.288386]                                       [<c1300385>] notify_and_destroy+0x27/0x3d
[  516.288386]                                       [<c1300490>] qdisc_graft+0xf5/0x1c6
[  516.288386]                                       [<c130110a>] tc_modify_qdisc+0x369/0x3b8
[  516.288386]                                       [<c12f8d09>] rtnetlink_rcv_msg+0x197/0x1b1
[  516.288386]                                       [<c1305cc0>] netlink_rcv_skb+0x30/0x75
[  516.288386]                                       [<c12f8b6a>] rtnetlink_rcv+0x1e/0x26
[  516.288386]                                       [<c1305b01>] netlink_unicast+0xc4/0x11a
[  516.288386]                                       [<c13061a2>] netlink_sendmsg+0x23a/0x252
[  516.288386]                                       [<c12e09fd>] __sock_sendmsg+0x4d/0x56
[  516.288386]                                       [<c12e0e42>] sock_sendmsg+0x95/0xab
[  516.288386]                                       [<c12e1024>] sys_sendmsg+0x13f/0x18f
[  516.288386]                                       [<c12e2676>] sys_socketcall+0x155/0x1a3
[  516.288386]                                       [<c13c5e25>] syscall_call+0x7/0xb
[  516.288386]  }
[  516.288386]  ... key      at: [<c1b8318c>] qdisc_tx_lock+0x0/0x8
[  516.288386]  ... acquired at:
[  516.288386]    [<c1049bf3>] check_usage_forwards+0x5d/0x68
[  516.288386]    [<c1049575>] mark_lock+0x102/0x1e0
[  516.288386]    [<c104a3c3>] __lock_acquire+0x2a8/0xbd6
[  516.288386]    [<c104ad9d>] lock_acquire+0xac/0xc8
[  516.288386]    [<c13c53ce>] _raw_spin_lock+0x25/0x34
[  516.288386]    [<c12eacda>] est_timer+0x62/0x1b4
[  516.288386]    [<c1033536>] run_timer_softirq+0x19e/0x263
[  516.288386]    [<c102d692>] __do_softirq+0xab/0x169
[  516.288386]    [<c102d77a>] do_softirq+0x2a/0x42
[  516.288386]    [<c102d8d6>] irq_exit+0x36/0x42
[  516.288386]    [<c1014705>] smp_apic_timer_interrupt+0x66/0x71
[  516.288386]    [<c13c5fdf>] apic_timer_interrupt+0x2f/0x34
[  516.288386]    [<c1001c13>] cpu_idle+0x31/0x5a
[  516.288386]    [<c13bc316>] rest_init+0xda/0xdf
[  516.288386]    [<c15ba7c3>] start_kernel+0x2d4/0x2d9
[  516.288386]    [<c15ba09f>] i386_start_kernel+0x9f/0xa7
[  516.288386] 
[  516.288386] 
[  516.288386] stack backtrace:
[  516.288386] Pid: 0, comm: swapper Not tainted 2.6.35b #7
[  516.288386] Call Trace:
[  516.288386]  [<c13c3a01>] ? printk+0xf/0x16
[  516.288386]  [<c1049b8b>] print_irq_inversion_bug+0xef/0xfa
[  516.288386]  [<c1049bf3>] check_usage_forwards+0x5d/0x68
[  516.288386]  [<c1049575>] mark_lock+0x102/0x1e0
[  516.288386]  [<c1049b96>] ? check_usage_forwards+0x0/0x68
[  516.288386]  [<c104a3c3>] __lock_acquire+0x2a8/0xbd6
[  516.288386]  [<c104a49a>] ? __lock_acquire+0x37f/0xbd6
[  516.288386]  [<c104ac2b>] ? __lock_acquire+0xb10/0xbd6
[  516.288386]  [<c104ad9d>] lock_acquire+0xac/0xc8
[  516.288386]  [<c12eacda>] ? est_timer+0x62/0x1b4
[  516.288386]  [<c13c53ce>] _raw_spin_lock+0x25/0x34
[  516.288386]  [<c12eacda>] ? est_timer+0x62/0x1b4
[  516.288386]  [<c12eacda>] est_timer+0x62/0x1b4
[  516.288386]  [<c10334b5>] ? run_timer_softirq+0x11d/0x263
[  516.288386]  [<c1033536>] run_timer_softirq+0x19e/0x263
[  516.288386]  [<c12eac78>] ? est_timer+0x0/0x1b4
[  516.288386]  [<c102d692>] __do_softirq+0xab/0x169
[  516.288386]  [<c102d77a>] do_softirq+0x2a/0x42
[  516.288386]  [<c102d8d6>] irq_exit+0x36/0x42
[  516.288386]  [<c1014705>] smp_apic_timer_interrupt+0x66/0x71
[  516.288386]  [<c13c5fdf>] apic_timer_interrupt+0x2f/0x34
[  516.288386]  [<c104007b>] ? create_new_namespaces+0x37/0x127
[  516.288386]  [<c1007c0b>] ? default_idle+0x46/0x65
[  516.288386]  [<c1001c13>] cpu_idle+0x31/0x5a
[  516.288386]  [<c13bc316>] rest_init+0xda/0xdf
[  516.288386]  [<c15ba7c3>] start_kernel+0x2d4/0x2d9
[  516.288386]  [<c15ba09f>] i386_start_kernel+0x9f/0xa7

----------->

This patch fixes a lockdep warning:

[  516.287584] =========================================================
[  516.288386] [ INFO: possible irq lock inversion dependency detected ]
[  516.288386] 2.6.35b #7
[  516.288386] ---------------------------------------------------------
[  516.288386] swapper/0 just changed the state of lock:
[  516.288386]  (&qdisc_tx_lock){+.-...}, at: [<c12eacda>] est_timer+0x62/0x1b4
[  516.288386] but this lock took another, SOFTIRQ-unsafe lock in the past:
[  516.288386]  (est_tree_lock){+.+...}
[  516.288386] 
[  516.288386] and interrupts could create inverse lock ordering between them.
...

So, est_tree_lock needs BH protection because it's taken by
qdisc_tx_lock, which is used both in BH and process contexts.
(Full warning with this patch at netdev, 02 Sep 2010.)

Fixes commit: ae638c47dc040b8def16d05dc6acdd527628f231

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 9fbe7f7..6743146 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -232,7 +232,7 @@ int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 	est->last_packets = bstats->packets;
 	est->avpps = rate_est->pps<<10;
 
-	spin_lock(&est_tree_lock);
+	spin_lock_bh(&est_tree_lock);
 	if (!elist[idx].timer.function) {
 		INIT_LIST_HEAD(&elist[idx].list);
 		setup_timer(&elist[idx].timer, est_timer, idx);
@@ -243,7 +243,7 @@ int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 
 	list_add_rcu(&est->list, &elist[idx].list);
 	gen_add_node(est);
-	spin_unlock(&est_tree_lock);
+	spin_unlock_bh(&est_tree_lock);
 
 	return 0;
 }
@@ -270,7 +270,7 @@ void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
 {
 	struct gen_estimator *e;
 
-	spin_lock(&est_tree_lock);
+	spin_lock_bh(&est_tree_lock);
 	while ((e = gen_find_node(bstats, rate_est))) {
 		rb_erase(&e->node, &est_root);
 
@@ -281,7 +281,7 @@ void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
 		list_del_rcu(&e->list);
 		call_rcu(&e->e_rcu, __gen_kill_estimator);
 	}
-	spin_unlock(&est_tree_lock);
+	spin_unlock_bh(&est_tree_lock);
 }
 EXPORT_SYMBOL(gen_kill_estimator);
 
@@ -320,9 +320,9 @@ bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats,
 
 	ASSERT_RTNL();
 
-	spin_lock(&est_tree_lock);
+	spin_lock_bh(&est_tree_lock);
 	res = gen_find_node(bstats, rate_est) != NULL;
-	spin_unlock(&est_tree_lock);
+	spin_unlock_bh(&est_tree_lock);
 
 	return res;
 }
