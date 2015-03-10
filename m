From: Sabrina Dubroca <sd@queasysnail.net>
Subject: suspicious RCU usage in fib_table_flush_external
Date: Tue, 10 Mar 2015 19:35:55 +0100
Message-ID: <20150310183555.GB1743@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:52454 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753438AbbCJSgA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 14:36:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I ran into this while deleting a netns with some routes:

===============================
[ INFO: suspicious RCU usage. ]
4.0.0-rc2-00722-g8ac467e837a2-dirty #674 Not tainted
-------------------------------
net/ipv4/fib_trie.c:1606 suspicious rcu_dereference_protected() usage!
other info that might help us debug this:

rcu_scheduler_active = 1, debug_locks = 1
4 locks held by kworker/u4:1/50:
 #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff81086525>] process_one_work+0x155/0x880
 #1:  (net_cleanup_work){+.+.+.}, at: [<ffffffff81086525>] process_one_work+0x155/0x880
 #2:  (net_mutex){+.+.+.}, at: [<ffffffff81647cfd>] cleanup_net+0x7d/0x230
 #3:  (&(&net->rules_mod_lock)->rlock){+.+...}, at: [<ffffffff81674ce4>] fib_rules_unregister+0x34/0x100
 stack backtrace:
CPU: 1 PID: 50 Comm: kworker/u4:1 Not tainted 4.0.0-rc2-00722-g8ac467e837a2-dirty #674
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140617_173321-var-lib-archbuild-testing-x86_64-tobias 04/01/2014
Workqueue: netns cleanup_net
 0000000000000001 ffff88001dffbba8 ffffffff81835bd0 0000000000000011
 ffff88001dd95690 ffff88001dffbbd8 ffffffff810b5505 0000000000000001
 0000000000000001 ffff88001da86270 ffff88001d528008 ffff88001dffbc08
Call Trace:
 [<ffffffff81835bd0>] dump_stack+0x4c/0x6e
 [<ffffffff810b5505>] lockdep_rcu_suspicious+0xd5/0x110
 [<ffffffff81710421>] fib_table_flush_external+0xe1/0x130
 [<ffffffff81708808>] fib_flush_external+0x38/0x60
 [<ffffffff81719dee>] fib4_rule_delete+0x2e/0x30
 [<ffffffff81674d4b>] fib_rules_unregister+0x9b/0x100
 [<ffffffff8171a2a5>] fib4_rules_exit+0x15/0x20
 [<ffffffff817078ab>] ip_fib_net_exit+0x1b/0x120
 [<ffffffff817079e5>] fib_net_exit+0x35/0x40



since fib_table_flush_external wants RTNL, should we just move
rtnl_lock() before fib4_rules_exit in ip_fib_net_exit?


diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index e067770235bf..ed94bc80eb78 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1126,11 +1126,12 @@ static void ip_fib_net_exit(struct net *net)
 {
 	unsigned int i;
 
+	rtnl_lock();
+
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	fib4_rules_exit(net);
 #endif
 
-	rtnl_lock();
 	for (i = 0; i < FIB_TABLE_HASHSZ; i++) {
 		struct hlist_head *head = &net->ipv4.fib_table_hash[i];
 		struct hlist_node *tmp;

-- 
Sabrina
