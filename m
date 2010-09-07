From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] ipv4: Suppress lockdep-RCU false positive in FIB trie (3)
Date: Tue, 7 Sep 2010 19:51:17 +0200
Message-ID: <20100907175117.GA1993@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:56482 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932099Ab0IGRvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 13:51:24 -0400
Received: by ewy23 with SMTP id 23so2523515ewy.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 10:51:23 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,
Here is one more of these warnings and a patch below:

Sep  5 23:52:33 del kernel: [46044.244833] ===================================================
Sep  5 23:52:33 del kernel: [46044.269681] [ INFO: suspicious rcu_dereference_check() usage. ]
Sep  5 23:52:33 del kernel: [46044.277000] ---------------------------------------------------
Sep  5 23:52:33 del kernel: [46044.285185] net/ipv4/fib_trie.c:1756 invoked rcu_dereference_check() without protection!
Sep  5 23:52:33 del kernel: [46044.293627] 
Sep  5 23:52:33 del kernel: [46044.293632] other info that might help us debug this:
Sep  5 23:52:33 del kernel: [46044.293634] 
Sep  5 23:52:33 del kernel: [46044.325333] 
Sep  5 23:52:33 del kernel: [46044.325335] rcu_scheduler_active = 1, debug_locks = 0
Sep  5 23:52:33 del kernel: [46044.348013] 1 lock held by pppd/1717:
Sep  5 23:52:33 del kernel: [46044.357548]  #0:  (rtnl_mutex){+.+.+.}, at: [<c125dc1f>] rtnl_lock+0xf/0x20
Sep  5 23:52:33 del kernel: [46044.367647] 
Sep  5 23:52:33 del kernel: [46044.367652] stack backtrace:
Sep  5 23:52:33 del kernel: [46044.387429] Pid: 1717, comm: pppd Not tainted 2.6.35.4.4a #3
Sep  5 23:52:33 del kernel: [46044.398764] Call Trace:
Sep  5 23:52:33 del kernel: [46044.409596]  [<c12f9aba>] ? printk+0x18/0x1e
Sep  5 23:52:33 del kernel: [46044.420761]  [<c1053969>] lockdep_rcu_dereference+0xa9/0xb0
Sep  5 23:52:33 del kernel: [46044.432229]  [<c12b7235>] trie_firstleaf+0x65/0x70
Sep  5 23:52:33 del kernel: [46044.443941]  [<c12b74d4>] fib_table_flush+0x14/0x170
Sep  5 23:52:33 del kernel: [46044.455823]  [<c1033e92>] ? local_bh_enable_ip+0x62/0xd0
Sep  5 23:52:33 del kernel: [46044.467995]  [<c12fc39f>] ? _raw_spin_unlock_bh+0x2f/0x40
Sep  5 23:52:33 del kernel: [46044.480404]  [<c12b24d0>] ? fib_sync_down_dev+0x120/0x180
Sep  5 23:52:33 del kernel: [46044.493025]  [<c12b069d>] fib_flush+0x2d/0x60
Sep  5 23:52:33 del kernel: [46044.505796]  [<c12b06f5>] fib_disable_ip+0x25/0x50
Sep  5 23:52:33 del kernel: [46044.518772]  [<c12b10d3>] fib_netdev_event+0x73/0xd0
Sep  5 23:52:33 del kernel: [46044.531918]  [<c1048dfd>] notifier_call_chain+0x2d/0x70
Sep  5 23:52:33 del kernel: [46044.545358]  [<c1048f0a>] raw_notifier_call_chain+0x1a/0x20
Sep  5 23:52:33 del kernel: [46044.559092]  [<c124f687>] call_netdevice_notifiers+0x27/0x60
Sep  5 23:52:33 del kernel: [46044.573037]  [<c124faec>] __dev_notify_flags+0x5c/0x80
Sep  5 23:52:33 del kernel: [46044.586489]  [<c124fb47>] dev_change_flags+0x37/0x60
Sep  5 23:52:33 del kernel: [46044.599394]  [<c12a8a8d>] devinet_ioctl+0x54d/0x630
Sep  5 23:52:33 del kernel: [46044.612277]  [<c12aabb7>] inet_ioctl+0x97/0xc0
Sep  5 23:52:34 del kernel: [46044.625208]  [<c123f6af>] sock_ioctl+0x6f/0x270
Sep  5 23:52:34 del kernel: [46044.638046]  [<c109d2b0>] ? handle_mm_fault+0x420/0x6c0
Sep  5 23:52:34 del kernel: [46044.650968]  [<c123f640>] ? sock_ioctl+0x0/0x270
Sep  5 23:52:34 del kernel: [46044.663865]  [<c10c3188>] vfs_ioctl+0x28/0xa0
Sep  5 23:52:34 del kernel: [46044.676556]  [<c10c38fa>] do_vfs_ioctl+0x6a/0x5c0
Sep  5 23:52:34 del kernel: [46044.688989]  [<c1048676>] ? up_read+0x16/0x30
Sep  5 23:52:34 del kernel: [46044.701411]  [<c1021376>] ? do_page_fault+0x1d6/0x3a0
Sep  5 23:52:34 del kernel: [46044.714223]  [<c10b6588>] ? fget_light+0xf8/0x2f0
Sep  5 23:52:34 del kernel: [46044.726601]  [<c1241f98>] ? sys_socketcall+0x208/0x2c0
Sep  5 23:52:34 del kernel: [46044.739140]  [<c10c3eb3>] sys_ioctl+0x63/0x70
Sep  5 23:52:34 del kernel: [46044.751967]  [<c12fca3d>] syscall_call+0x7/0xb
Sep  5 23:52:34 del kernel: [46044.764734]  [<c12f0000>] ? cookie_v6_check+0x3d0/0x630

-------------->

This patch fixes the warning:
 ===================================================
 [ INFO: suspicious rcu_dereference_check() usage. ]
 ---------------------------------------------------
 net/ipv4/fib_trie.c:1756 invoked rcu_dereference_check() without protection!
 
 other info that might help us debug this:
 
 
 rcu_scheduler_active = 1, debug_locks = 0
 1 lock held by pppd/1717:
  #0:  (rtnl_mutex){+.+.+.}, at: [<c125dc1f>] rtnl_lock+0xf/0x20
 
 stack backtrace:
 Pid: 1717, comm: pppd Not tainted 2.6.35.4a #3
 Call Trace:
  [<c12f9aba>] ? printk+0x18/0x1e
  [<c1053969>] lockdep_rcu_dereference+0xa9/0xb0
  [<c12b7235>] trie_firstleaf+0x65/0x70
  [<c12b74d4>] fib_table_flush+0x14/0x170
  ...

Allow trie_firstleaf() to be called either under rcu_read_lock()
protection or with RTNL held. The same annotation is added to
node_parent_rcu() to prevent a similar warning a bit later.

Followup of commits 634a4b20 and 4eaa0e3c.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 79d057a..4a8e370 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -186,7 +186,9 @@ static inline struct tnode *node_parent_rcu(struct node *node)
 {
 	struct tnode *ret = node_parent(node);
 
-	return rcu_dereference(ret);
+	return rcu_dereference_check(ret,
+				     rcu_read_lock_held() ||
+				     lockdep_rtnl_is_held());
 }
 
 /* Same as rcu_assign_pointer
@@ -1753,7 +1755,9 @@ static struct leaf *leaf_walk_rcu(struct tnode *p, struct node *c)
 
 static struct leaf *trie_firstleaf(struct trie *t)
 {
-	struct tnode *n = (struct tnode *) rcu_dereference(t->trie);
+	struct tnode *n = (struct tnode *) rcu_dereference_check(t->trie,
+							rcu_read_lock_held() ||
+							lockdep_rtnl_is_held());
 
 	if (!n)
 		return NULL;
