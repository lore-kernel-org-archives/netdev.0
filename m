From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 51/53] netfilter: nf_queue: only call synchronize_net twice if nf_queue is active
Date: Mon,  1 May 2017 12:47:18 +0200
Message-ID: <1493635640-24325-52-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

nf_unregister_net_hook(s) can avoid a second call to synchronize_net,
provided there is no nfqueue active in that net namespace (which is
the common case).

This also gets rid of the extra arg to nf_queue_nf_hook_drop(), normally
this gets called during netns cleanup so no packets should be queued.

For the rare case of base chain being unregistered or module removal
while nfqueue is in use the extra hiccup due to the packet drops isn't
a big deal.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_queue.h |  3 +--
 net/netfilter/core.c             | 21 ++++++++++++---------
 net/netfilter/nf_internals.h     |  2 +-
 net/netfilter/nf_queue.c         |  7 +++++--
 net/netfilter/nfnetlink_queue.c  | 18 ++++++++----------
 5 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
index 09948d10e38e..4454719ff849 100644
--- a/include/net/netfilter/nf_queue.h
+++ b/include/net/netfilter/nf_queue.h
@@ -24,8 +24,7 @@ struct nf_queue_entry {
 struct nf_queue_handler {
 	int		(*outfn)(struct nf_queue_entry *entry,
 				 unsigned int queuenum);
-	void		(*nf_hook_drop)(struct net *net,
-					const struct nf_hook_entry *hooks);
+	unsigned int	(*nf_hook_drop)(struct net *net);
 };
 
 void nf_register_queue_handler(struct net *net, const struct nf_queue_handler *qh);
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index b5d908851cc8..552d606e57ca 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -162,14 +162,17 @@ __nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 {
 	struct nf_hook_entry *p = __nf_unregister_net_hook(net, reg);
+	unsigned int nfq;
 
 	if (!p)
 		return;
 
 	synchronize_net();
-	nf_queue_nf_hook_drop(net, p);
+
 	/* other cpu might still process nfqueue verdict that used reg */
-	synchronize_net();
+	nfq = nf_queue_nf_hook_drop(net);
+	if (nfq)
+		synchronize_net();
 	kfree(p);
 }
 EXPORT_SYMBOL(nf_unregister_net_hook);
@@ -198,7 +201,7 @@ void nf_unregister_net_hooks(struct net *net, const struct nf_hook_ops *reg,
 			     unsigned int hookcount)
 {
 	struct nf_hook_entry *to_free[16];
-	unsigned int i, n;
+	unsigned int i, n, nfq;
 
 	do {
 		n = min_t(unsigned int, hookcount, ARRAY_SIZE(to_free));
@@ -208,12 +211,12 @@ void nf_unregister_net_hooks(struct net *net, const struct nf_hook_ops *reg,
 
 		synchronize_net();
 
-		for (i = 0; i < n; i++) {
-			if (to_free[i])
-				nf_queue_nf_hook_drop(net, to_free[i]);
-		}
-
-		synchronize_net();
+		/* need 2nd synchronize_net() if nfqueue is used, skb
+		 * can get reinjected right before nf_queue_hook_drop()
+		 */
+		nfq = nf_queue_nf_hook_drop(net);
+		if (nfq)
+			synchronize_net();
 
 		for (i = 0; i < n; i++)
 			kfree(to_free[i]);
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index c46d214d5323..bfa742da83af 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -14,7 +14,7 @@
 /* nf_queue.c */
 int nf_queue(struct sk_buff *skb, struct nf_hook_state *state,
 	     struct nf_hook_entry **entryp, unsigned int verdict);
-void nf_queue_nf_hook_drop(struct net *net, const struct nf_hook_entry *entry);
+unsigned int nf_queue_nf_hook_drop(struct net *net);
 int __init netfilter_queue_init(void);
 
 /* nf_log.c */
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 4a7662486f44..043850c9d154 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -96,15 +96,18 @@ void nf_queue_entry_get_refs(struct nf_queue_entry *entry)
 }
 EXPORT_SYMBOL_GPL(nf_queue_entry_get_refs);
 
-void nf_queue_nf_hook_drop(struct net *net, const struct nf_hook_entry *entry)
+unsigned int nf_queue_nf_hook_drop(struct net *net)
 {
 	const struct nf_queue_handler *qh;
+	unsigned int count = 0;
 
 	rcu_read_lock();
 	qh = rcu_dereference(net->nf.queue_handler);
 	if (qh)
-		qh->nf_hook_drop(net, entry);
+		count = qh->nf_hook_drop(net);
 	rcu_read_unlock();
+
+	return count;
 }
 
 static int __nf_queue(struct sk_buff *skb, const struct nf_hook_state *state,
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index d09ab49e102a..dd8ec5b0fcd9 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -922,16 +922,10 @@ static struct notifier_block nfqnl_dev_notifier = {
 	.notifier_call	= nfqnl_rcv_dev_event,
 };
 
-static int nf_hook_cmp(struct nf_queue_entry *entry, unsigned long entry_ptr)
-{
-	return rcu_access_pointer(entry->hook) ==
-		(struct nf_hook_entry *)entry_ptr;
-}
-
-static void nfqnl_nf_hook_drop(struct net *net,
-			       const struct nf_hook_entry *hook)
+static unsigned int nfqnl_nf_hook_drop(struct net *net)
 {
 	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
+	unsigned int instances = 0;
 	int i;
 
 	rcu_read_lock();
@@ -939,10 +933,14 @@ static void nfqnl_nf_hook_drop(struct net *net,
 		struct nfqnl_instance *inst;
 		struct hlist_head *head = &q->instance_table[i];
 
-		hlist_for_each_entry_rcu(inst, head, hlist)
-			nfqnl_flush(inst, nf_hook_cmp, (unsigned long)hook);
+		hlist_for_each_entry_rcu(inst, head, hlist) {
+			nfqnl_flush(inst, NULL, 0);
+			instances++;
+		}
 	}
 	rcu_read_unlock();
+
+	return instances;
 }
 
 static int
-- 
2.1.4

