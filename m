From: pablo@netfilter.org
Subject: [PATCH 23/25] netfilter: pass 'nf_hook_ops' instead of 'list_head' to nf_iterate()
Date: Tue,  4 Sep 2012 01:54:10 +0200
Message-ID: <1346716452-3080-24-git-send-email-pablo@netfilter.org>
References: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37182 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756619Ab2ICX4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 19:56:09 -0400
In-Reply-To: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Wang <wangyun@linux.vnet.ibm.com>

Since 'list_for_each_continue_rcu' has already been replaced by
'list_for_each_entry_continue_rcu', pass 'list_head' to nf_iterate() as a
parameter can not benefit us any more.

This patch will replace 'list_head' with 'nf_hook_ops' as the parameter of
nf_iterate() to save code.

Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c         |   24 ++++++++++--------------
 net/netfilter/nf_internals.h |    2 +-
 net/netfilter/nf_queue.c     |    6 +++---
 3 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e61b3ac..0b119d9 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -126,42 +126,38 @@ unsigned int nf_iterate(struct list_head *head,
 			unsigned int hook,
 			const struct net_device *indev,
 			const struct net_device *outdev,
-			struct list_head **i,
+			struct nf_hook_ops **elemp,
 			int (*okfn)(struct sk_buff *),
 			int hook_thresh)
 {
 	unsigned int verdict;
-	struct nf_hook_ops *elem = list_entry_rcu(*i, struct nf_hook_ops, list);
 
 	/*
 	 * The caller must not block between calls to this
 	 * function because of risk of continuing from deleted element.
 	 */
-	list_for_each_entry_continue_rcu(elem, head, list) {
-		if (hook_thresh > elem->priority)
+	list_for_each_entry_continue_rcu((*elemp), head, list) {
+		if (hook_thresh > (*elemp)->priority)
 			continue;
 
 		/* Optimization: we don't need to hold module
 		   reference here, since function can't sleep. --RR */
 repeat:
-		verdict = elem->hook(hook, skb, indev, outdev, okfn);
+		verdict = (*elemp)->hook(hook, skb, indev, outdev, okfn);
 		if (verdict != NF_ACCEPT) {
 #ifdef CONFIG_NETFILTER_DEBUG
 			if (unlikely((verdict & NF_VERDICT_MASK)
 							> NF_MAX_VERDICT)) {
 				NFDEBUG("Evil return from %p(%u).\n",
-					elem->hook, hook);
+					(*elemp)->hook, hook);
 				continue;
 			}
 #endif
-			if (verdict != NF_REPEAT) {
-				*i = &elem->list;
+			if (verdict != NF_REPEAT)
 				return verdict;
-			}
 			goto repeat;
 		}
 	}
-	*i = &elem->list;
 	return NF_ACCEPT;
 }
 
@@ -174,14 +170,14 @@ int nf_hook_slow(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
 		 int (*okfn)(struct sk_buff *),
 		 int hook_thresh)
 {
-	struct list_head *elem;
+	struct nf_hook_ops *elem;
 	unsigned int verdict;
 	int ret = 0;
 
 	/* We may already have this, but read-locks nest anyway */
 	rcu_read_lock();
 
-	elem = &nf_hooks[pf][hook];
+	elem = list_entry_rcu(&nf_hooks[pf][hook], struct nf_hook_ops, list);
 next_hook:
 	verdict = nf_iterate(&nf_hooks[pf][hook], skb, hook, indev,
 			     outdev, &elem, okfn, hook_thresh);
@@ -193,8 +189,8 @@ next_hook:
 		if (ret == 0)
 			ret = -EPERM;
 	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
-		int err = nf_queue(skb, elem, pf, hook, indev, outdev, okfn,
-						verdict >> NF_VERDICT_QBITS);
+		int err = nf_queue(skb, &elem->list, pf, hook, indev, outdev,
+					okfn, verdict >> NF_VERDICT_QBITS);
 		if (err < 0) {
 			if (err == -ECANCELED)
 				goto next_hook;
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index 770f764..2886231 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -18,7 +18,7 @@ extern unsigned int nf_iterate(struct list_head *head,
 				unsigned int hook,
 				const struct net_device *indev,
 				const struct net_device *outdev,
-				struct list_head **i,
+				struct nf_hook_ops **elemp,
 				int (*okfn)(struct sk_buff *),
 				int hook_thresh);
 
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index ce60cf0..29fe102 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -287,7 +287,7 @@ int nf_queue(struct sk_buff *skb,
 void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 {
 	struct sk_buff *skb = entry->skb;
-	struct list_head *elem = &entry->elem->list;
+	struct nf_hook_ops *elem = entry->elem;
 	const struct nf_afinfo *afinfo;
 	int err;
 
@@ -297,7 +297,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 
 	/* Continue traversal iff userspace said ok... */
 	if (verdict == NF_REPEAT) {
-		elem = elem->prev;
+		elem = list_entry(elem->list.prev, struct nf_hook_ops, list);
 		verdict = NF_ACCEPT;
 	}
 
@@ -323,7 +323,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 		local_bh_enable();
 		break;
 	case NF_QUEUE:
-		err = __nf_queue(skb, elem, entry->pf, entry->hook,
+		err = __nf_queue(skb, &elem->list, entry->pf, entry->hook,
 				 entry->indev, entry->outdev, entry->okfn,
 				 verdict >> NF_VERDICT_QBITS);
 		if (err < 0) {
-- 
1.7.10.4
