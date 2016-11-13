From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/39] netfilter: merge nf_iterate() into nf_hook_slow()
Date: Sun, 13 Nov 2016 23:25:03 +0100
Message-ID: <1479075933-4491-10-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nf_iterate() has become rather simple, we can integrate this code into
nf_hook_slow() to reduce the amount of LOC in the core path.

However, we still need nf_iterate() around for nf_queue packet handling,
so move this function there where we only need it. I think it should be
possible to refactor nf_queue code to get rid of it definitely, but
given this is slow path anyway, let's have a look this later.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c         | 73 +++++++++++++++++---------------------------
 net/netfilter/nf_internals.h |  5 ---
 net/netfilter/nf_queue.c     | 20 ++++++++++++
 3 files changed, 48 insertions(+), 50 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index ebece48b8392..bd9272eeccb5 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -302,26 +302,6 @@ void _nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n)
 }
 EXPORT_SYMBOL(_nf_unregister_hooks);
 
-unsigned int nf_iterate(struct sk_buff *skb,
-			struct nf_hook_state *state,
-			struct nf_hook_entry **entryp)
-{
-	unsigned int verdict;
-
-	do {
-repeat:
-		verdict = (*entryp)->ops.hook((*entryp)->ops.priv, skb, state);
-		if (verdict != NF_ACCEPT) {
-			if (verdict != NF_REPEAT)
-				return verdict;
-			goto repeat;
-		}
-		*entryp = rcu_dereference((*entryp)->next);
-	} while (*entryp);
-	return NF_ACCEPT;
-}
-
-
 /* Returns 1 if okfn() needs to be executed by the caller,
  * -EPERM for NF_DROP, 0 otherwise.  Caller must hold rcu_read_lock. */
 int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state,
@@ -330,31 +310,34 @@ int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state,
 	unsigned int verdict;
 	int ret;
 
-next_hook:
-	verdict = nf_iterate(skb, state, &entry);
-	switch (verdict & NF_VERDICT_MASK) {
-	case NF_ACCEPT:
-		ret = 1;
-		break;
-	case NF_DROP:
-		kfree_skb(skb);
-		ret = NF_DROP_GETERR(verdict);
-		if (ret == 0)
-			ret = -EPERM;
-		break;
-	case NF_QUEUE:
-		ret = nf_queue(skb, state, &entry, verdict);
-		if (ret == 1 && entry)
-			goto next_hook;
-		/* Fall through. */
-	default:
-		/* Implicit handling for NF_STOLEN, as well as any other non
-		 * conventional verdicts.
-		 */
-		ret = 0;
-		break;
-	}
-	return ret;
+	do {
+		verdict = entry->ops.hook(entry->ops.priv, skb, state);
+		switch (verdict & NF_VERDICT_MASK) {
+		case NF_ACCEPT:
+			entry = rcu_dereference(entry->next);
+			break;
+		case NF_DROP:
+			kfree_skb(skb);
+			ret = NF_DROP_GETERR(verdict);
+			if (ret == 0)
+				ret = -EPERM;
+			return ret;
+		case NF_REPEAT:
+			continue;
+		case NF_QUEUE:
+			ret = nf_queue(skb, state, &entry, verdict);
+			if (ret == 1 && entry)
+				continue;
+			return ret;
+		default:
+			/* Implicit handling for NF_STOLEN, as well as any other
+			 * non conventional verdicts.
+			 */
+			return 0;
+		}
+	} while (entry);
+
+	return 1;
 }
 EXPORT_SYMBOL(nf_hook_slow);
 
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index 9fdb655f85bc..c46d214d5323 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -11,11 +11,6 @@
 #define NFDEBUG(format, args...)
 #endif
 
-
-/* core.c */
-unsigned int nf_iterate(struct sk_buff *skb, struct nf_hook_state *state,
-			struct nf_hook_entry **entryp);
-
 /* nf_queue.c */
 int nf_queue(struct sk_buff *skb, struct nf_hook_state *state,
 	     struct nf_hook_entry **entryp, unsigned int verdict);
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 2e39e38ae1c7..77cba9f6ccb6 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -177,6 +177,26 @@ int nf_queue(struct sk_buff *skb, struct nf_hook_state *state,
 	return 0;
 }
 
+static unsigned int nf_iterate(struct sk_buff *skb,
+			       struct nf_hook_state *state,
+			       struct nf_hook_entry **entryp)
+{
+	unsigned int verdict;
+
+	do {
+repeat:
+		verdict = (*entryp)->ops.hook((*entryp)->ops.priv, skb, state);
+		if (verdict != NF_ACCEPT) {
+			if (verdict != NF_REPEAT)
+				return verdict;
+			goto repeat;
+		}
+		*entryp = rcu_dereference((*entryp)->next);
+	} while (*entryp);
+
+	return NF_ACCEPT;
+}
+
 void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 {
 	struct nf_hook_entry *hook_entry = entry->hook;
-- 
2.1.4

