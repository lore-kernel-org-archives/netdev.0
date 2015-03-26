From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] fib: move fib_rules_cleanup_ops() under rtnl lock
Date: Thu, 26 Mar 2015 14:02:49 -0700
Message-ID: <1427403769-31208-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35075 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbbCZVC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 17:02:57 -0400
Received: by pdbop1 with SMTP id op1so74173168pdb.2
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 14:02:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ops->rules_list is protected by rtnl_lock + RCU,
there is no reason to take net->rules_mod_lock here.
Also, ops->delete() needs to be called with rtnl_lock
too. The problem exists before, just it is exposed
recently due to the fib local/main table change.

This fixes the following warning:

 BUG: sleeping function called from invalid context at mm/slub.c:1268
 in_atomic(): 1, irqs_disabled(): 0, pid: 6, name: kworker/u8:0
 INFO: lockdep is turned off.
 CPU: 3 PID: 6 Comm: kworker/u8:0 Tainted: G        W       4.0.0-rc5+ #895
 Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
 Workqueue: netns cleanup_net
  0000000000000006 ffff88011953fa68 ffffffff81a203b6 000000002c3a2c39
  ffff88011952a680 ffff88011953fa98 ffffffff8109daf0 ffff8801186c6aa8
  ffffffff81fbc9e5 00000000000004f4 0000000000000000 ffff88011953fac8
 Call Trace:
  [<ffffffff81a203b6>] dump_stack+0x4c/0x65
  [<ffffffff8109daf0>] ___might_sleep+0x1c3/0x1cb
  [<ffffffff8109db70>] __might_sleep+0x78/0x80
  [<ffffffff8117a60e>] slab_pre_alloc_hook+0x31/0x8f
  [<ffffffff8117d4f6>] __kmalloc+0x69/0x14e
  [<ffffffff818ed0e1>] ? kzalloc.constprop.20+0xe/0x10
  [<ffffffff818ed0e1>] kzalloc.constprop.20+0xe/0x10
  [<ffffffff818ef622>] fib_trie_table+0x27/0x8b
  [<ffffffff818ef6bd>] fib_trie_unmerge+0x37/0x2a6
  [<ffffffff810b06e1>] ? arch_local_irq_save+0x9/0xc
  [<ffffffff818e9793>] fib_unmerge+0x2d/0xb3
  [<ffffffff818f5f56>] fib4_rule_delete+0x1f/0x52
  [<ffffffff817f1c3f>] ? fib_rules_unregister+0x30/0xb2
  [<ffffffff817f1c8b>] fib_rules_unregister+0x7c/0xb2
  [<ffffffff818f64a1>] fib4_rules_exit+0x15/0x18
  [<ffffffff818e8c0a>] ip_fib_net_exit+0x23/0xf2
  [<ffffffff818e91f8>] fib_net_exit+0x32/0x36
  [<ffffffff817c8352>] ops_exit_list+0x45/0x57
  [<ffffffff817c8d3d>] cleanup_net+0x13c/0x1cd
  [<ffffffff8108b05d>] process_one_work+0x255/0x4ad
  [<ffffffff8108af69>] ? process_one_work+0x161/0x4ad
  [<ffffffff8108b4b1>] worker_thread+0x1cd/0x2ab
  [<ffffffff8108b2e4>] ? process_scheduled_works+0x2f/0x2f
  [<ffffffff81090686>] kthread+0xd4/0xdc
  [<ffffffff8109ec8f>] ? local_clock+0x19/0x22
  [<ffffffff810905b2>] ? __kthread_parkme+0x83/0x83
  [<ffffffff81a2c0c8>] ret_from_fork+0x58/0x90
  [<ffffffff810905b2>] ? __kthread_parkme+0x83/0x83

Fixes: 0ddcf43d5d4a ("ipv4: FIB Local/MAIN table collapse")
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/fib_rules.c    | 5 ++++-
 net/ipv4/fib_frontend.c | 3 +--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 68ea695..0149977 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -165,9 +165,12 @@ void fib_rules_unregister(struct fib_rules_ops *ops)
 
 	spin_lock(&net->rules_mod_lock);
 	list_del_rcu(&ops->list);
-	fib_rules_cleanup_ops(ops);
 	spin_unlock(&net->rules_mod_lock);
 
+	rtnl_lock();
+	fib_rules_cleanup_ops(ops);
+	rtnl_unlock();
+
 	kfree_rcu(ops, rcu);
 }
 EXPORT_SYMBOL_GPL(fib_rules_unregister);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index e5b6b05..3e40b01 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1174,11 +1174,10 @@ static void ip_fib_net_exit(struct net *net)
 {
 	unsigned int i;
 
-	rtnl_lock();
-
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	fib4_rules_exit(net);
 #endif
+	rtnl_lock();
 
 	for (i = 0; i < FIB_TABLE_HASHSZ; i++) {
 		struct hlist_head *head = &net->ipv4.fib_table_hash[i];
-- 
1.8.3.1
