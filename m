From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/18] netfilter: nf_queue: fix nf_queue_nf_hook_drop()
Date: Tue,  4 Aug 2015 12:02:42 +0200
Message-ID: <1438682568-8346-13-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56062 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933117AbbHDJ5f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 05:57:35 -0400
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function reacquires the rtnl_lock() which is already held by
nf_unregister_hook().

This can be triggered via: modprobe nf_conntrack_ipv4 && rmmod nf_conntrack_ipv4

[  720.628746] INFO: task rmmod:3578 blocked for more than 120 seconds.
[  720.628749]       Not tainted 4.2.0-rc2+ #113
[  720.628752] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  720.628754] rmmod           D ffff8800ca46fd58     0  3578   3571 0x00000080
[...]
[  720.628783] Call Trace:
[  720.628790]  [<ffffffff8152ea0b>] schedule+0x6b/0x90
[  720.628795]  [<ffffffff8152ecb3>] schedule_preempt_disabled+0x13/0x20
[  720.628799]  [<ffffffff8152ff55>] mutex_lock_nested+0x1f5/0x380
[  720.628803]  [<ffffffff81462622>] ? rtnl_lock+0x12/0x20
[  720.628807]  [<ffffffff81462622>] ? rtnl_lock+0x12/0x20
[  720.628812]  [<ffffffff81462622>] rtnl_lock+0x12/0x20
[  720.628817]  [<ffffffff8148ab25>] nf_queue_nf_hook_drop+0x15/0x160
[  720.628825]  [<ffffffff81488d48>] nf_unregister_net_hook+0x168/0x190
[  720.628831]  [<ffffffff81488e24>] nf_unregister_hook+0x64/0x80
[  720.628837]  [<ffffffff81488e60>] nf_unregister_hooks+0x20/0x30
[...]

Moreover, nf_unregister_net_hook() should only destroy the queue for this
netns, not for every netns.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Fixes: 085db2c04557 ("netfilter: Per network namespace netfilter hooks.")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/core.c         |    2 +-
 net/netfilter/nf_internals.h |    2 +-
 net/netfilter/nf_queue.c     |   12 +++---------
 3 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 87d237d..12504fbb 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -154,7 +154,7 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
 	synchronize_net();
-	nf_queue_nf_hook_drop(elem);
+	nf_queue_nf_hook_drop(net, elem);
 	kfree(elem);
 }
 EXPORT_SYMBOL(nf_unregister_net_hook);
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index 3992106..0655225 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -19,7 +19,7 @@ unsigned int nf_iterate(struct list_head *head, struct sk_buff *skb,
 /* nf_queue.c */
 int nf_queue(struct sk_buff *skb, struct nf_hook_ops *elem,
 	     struct nf_hook_state *state, unsigned int queuenum);
-void nf_queue_nf_hook_drop(struct nf_hook_ops *ops);
+void nf_queue_nf_hook_drop(struct net *net, struct nf_hook_ops *ops);
 int __init netfilter_queue_init(void);
 
 /* nf_log.c */
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 8a8b2ab..96777f9 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -105,21 +105,15 @@ bool nf_queue_entry_get_refs(struct nf_queue_entry *entry)
 }
 EXPORT_SYMBOL_GPL(nf_queue_entry_get_refs);
 
-void nf_queue_nf_hook_drop(struct nf_hook_ops *ops)
+void nf_queue_nf_hook_drop(struct net *net, struct nf_hook_ops *ops)
 {
 	const struct nf_queue_handler *qh;
-	struct net *net;
 
-	rtnl_lock();
 	rcu_read_lock();
 	qh = rcu_dereference(queue_handler);
-	if (qh) {
-		for_each_net(net) {
-			qh->nf_hook_drop(net, ops);
-		}
-	}
+	if (qh)
+		qh->nf_hook_drop(net, ops);
 	rcu_read_unlock();
-	rtnl_unlock();
 }
 
 /*
-- 
1.7.10.4
