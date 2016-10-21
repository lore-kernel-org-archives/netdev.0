From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/13] netfilter: fix nf_queue handling
Date: Fri, 21 Oct 2016 12:12:23 +0200
Message-ID: <1477044743-18948-14-git-send-email-pablo@netfilter.org>
References: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nf_queue handling is broken since e3b37f11e6e4 ("netfilter: replace
list_head with single linked list") for two reasons:

1) If the bypass flag is set on, there are no userspace listeners and
   we still have more hook entries to iterate over, then jump to the
   next hook. Otherwise accept the packet. On nf_reinject() path, the
   okfn() needs to be invoked.

2) We should not re-enter the same hook on packet reinjection. If the
   packet is accepted, we have to skip the current hook from where the
   packet was enqueued, otherwise the packets gets enqueued over and
   over again.

This restores the previous list_for_each_entry_continue() behaviour
happening from nf_iterate() that was dealing with these two cases.
This patch introduces a new nf_queue() wrapper function so this fix
becomes simpler.

Fixes: e3b37f11e6e4 ("netfilter: replace list_head with single linked list")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c         | 13 +++---------
 net/netfilter/nf_internals.h |  2 +-
 net/netfilter/nf_queue.c     | 48 +++++++++++++++++++++++++++++---------------
 3 files changed, 36 insertions(+), 27 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index fcb5d1df11e9..004af030ef1a 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -361,16 +361,9 @@ int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state)
 		if (ret == 0)
 			ret = -EPERM;
 	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
-		int err;
-
-		RCU_INIT_POINTER(state->hook_entries, entry);
-		err = nf_queue(skb, state, verdict >> NF_VERDICT_QBITS);
-		if (err < 0) {
-			if (err == -ESRCH &&
-			   (verdict & NF_VERDICT_FLAG_QUEUE_BYPASS))
-				goto next_hook;
-			kfree_skb(skb);
-		}
+		ret = nf_queue(skb, state, &entry, verdict);
+		if (ret == 1 && entry)
+			goto next_hook;
 	}
 	return ret;
 }
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index e0adb5959342..9fdb655f85bc 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -18,7 +18,7 @@ unsigned int nf_iterate(struct sk_buff *skb, struct nf_hook_state *state,
 
 /* nf_queue.c */
 int nf_queue(struct sk_buff *skb, struct nf_hook_state *state,
-	     unsigned int queuenum);
+	     struct nf_hook_entry **entryp, unsigned int verdict);
 void nf_queue_nf_hook_drop(struct net *net, const struct nf_hook_entry *entry);
 int __init netfilter_queue_init(void);
 
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 96964a0070e1..8f08d759844a 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -107,13 +107,8 @@ void nf_queue_nf_hook_drop(struct net *net, const struct nf_hook_entry *entry)
 	rcu_read_unlock();
 }
 
-/*
- * Any packet that leaves via this function must come back
- * through nf_reinject().
- */
-int nf_queue(struct sk_buff *skb,
-	     struct nf_hook_state *state,
-	     unsigned int queuenum)
+static int __nf_queue(struct sk_buff *skb, const struct nf_hook_state *state,
+		      unsigned int queuenum)
 {
 	int status = -ENOENT;
 	struct nf_queue_entry *entry = NULL;
@@ -161,6 +156,27 @@ int nf_queue(struct sk_buff *skb,
 	return status;
 }
 
+/* Packets leaving via this function must come back through nf_reinject(). */
+int nf_queue(struct sk_buff *skb, struct nf_hook_state *state,
+	     struct nf_hook_entry **entryp, unsigned int verdict)
+{
+	struct nf_hook_entry *entry = *entryp;
+	int ret;
+
+	RCU_INIT_POINTER(state->hook_entries, entry);
+	ret = __nf_queue(skb, state, verdict >> NF_VERDICT_QBITS);
+	if (ret < 0) {
+		if (ret == -ESRCH &&
+		    (verdict & NF_VERDICT_FLAG_QUEUE_BYPASS)) {
+			*entryp = rcu_dereference(entry->next);
+			return 1;
+		}
+		kfree_skb(skb);
+	}
+
+	return 0;
+}
+
 void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 {
 	struct nf_hook_entry *hook_entry;
@@ -187,26 +203,26 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 	entry->state.thresh = INT_MIN;
 
 	if (verdict == NF_ACCEPT) {
-	next_hook:
-		verdict = nf_iterate(skb, &entry->state, &hook_entry);
+		hook_entry = rcu_dereference(hook_entry->next);
+		if (hook_entry)
+next_hook:
+			verdict = nf_iterate(skb, &entry->state, &hook_entry);
 	}
 
 	switch (verdict & NF_VERDICT_MASK) {
 	case NF_ACCEPT:
 	case NF_STOP:
+okfn:
 		local_bh_disable();
 		entry->state.okfn(entry->state.net, entry->state.sk, skb);
 		local_bh_enable();
 		break;
 	case NF_QUEUE:
-		RCU_INIT_POINTER(entry->state.hook_entries, hook_entry);
-		err = nf_queue(skb, &entry->state,
-			       verdict >> NF_VERDICT_QBITS);
-		if (err < 0) {
-			if (err == -ESRCH &&
-			   (verdict & NF_VERDICT_FLAG_QUEUE_BYPASS))
+		err = nf_queue(skb, &entry->state, &hook_entry, verdict);
+		if (err == 1) {
+			if (hook_entry)
 				goto next_hook;
-			kfree_skb(skb);
+			goto okfn;
 		}
 		break;
 	case NF_STOLEN:
-- 
2.1.4

