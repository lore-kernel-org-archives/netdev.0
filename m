From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 28/35] netfilter: make nf_queue_entry_get_refs return void
Date: Sat, 17 Oct 2015 13:33:03 +0200
Message-ID: <1445081590-2924-29-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48443 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752833AbbJQL0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:31 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

We don't care if module is being unloaded anymore since hook unregister
handling will destroy queue entries using that hook.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_queue.h |  2 +-
 net/netfilter/core.c             |  2 --
 net/netfilter/nf_queue.c         | 11 ++---------
 net/netfilter/nfnetlink_queue.c  | 11 ++++-------
 4 files changed, 7 insertions(+), 19 deletions(-)

diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
index e863585..9c5638a 100644
--- a/include/net/netfilter/nf_queue.h
+++ b/include/net/netfilter/nf_queue.h
@@ -32,7 +32,7 @@ void nf_register_queue_handler(const struct nf_queue_handler *qh);
 void nf_unregister_queue_handler(void);
 void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict);
 
-bool nf_queue_entry_get_refs(struct nf_queue_entry *entry);
+void nf_queue_entry_get_refs(struct nf_queue_entry *entry);
 void nf_queue_entry_release_refs(struct nf_queue_entry *entry);
 
 static inline void init_hashrandom(u32 *jhash_initval)
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 32a2894..09e661c 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -313,8 +313,6 @@ next_hook:
 		int err = nf_queue(skb, elem, state,
 				   verdict >> NF_VERDICT_QBITS);
 		if (err < 0) {
-			if (err == -ECANCELED)
-				goto next_hook;
 			if (err == -ESRCH &&
 			   (verdict & NF_VERDICT_FLAG_QUEUE_BYPASS))
 				goto next_hook;
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index eef1c50..efc9688 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -73,7 +73,7 @@ void nf_queue_entry_release_refs(struct nf_queue_entry *entry)
 EXPORT_SYMBOL_GPL(nf_queue_entry_release_refs);
 
 /* Bump dev refs so they don't vanish while packet is out */
-bool nf_queue_entry_get_refs(struct nf_queue_entry *entry)
+void nf_queue_entry_get_refs(struct nf_queue_entry *entry)
 {
 	struct nf_hook_state *state = &entry->state;
 
@@ -95,8 +95,6 @@ bool nf_queue_entry_get_refs(struct nf_queue_entry *entry)
 			dev_hold(physdev);
 	}
 #endif
-
-	return true;
 }
 EXPORT_SYMBOL_GPL(nf_queue_entry_get_refs);
 
@@ -151,10 +149,7 @@ int nf_queue(struct sk_buff *skb,
 		.size	= sizeof(*entry) + afinfo->route_key_size,
 	};
 
-	if (!nf_queue_entry_get_refs(entry)) {
-		status = -ECANCELED;
-		goto err_unlock;
-	}
+	nf_queue_entry_get_refs(entry);
 	skb_dst_force(skb);
 	afinfo->saveroute(skb, entry);
 	status = qh->outfn(entry, queuenum);
@@ -215,8 +210,6 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 		err = nf_queue(skb, elem, &entry->state,
 			       verdict >> NF_VERDICT_QBITS);
 		if (err < 0) {
-			if (err == -ECANCELED)
-				goto next_hook;
 			if (err == -ESRCH &&
 			   (verdict & NF_VERDICT_FLAG_QUEUE_BYPASS))
 				goto next_hook;
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index a659e57..7d81d28 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -606,12 +606,9 @@ static struct nf_queue_entry *
 nf_queue_entry_dup(struct nf_queue_entry *e)
 {
 	struct nf_queue_entry *entry = kmemdup(e, e->size, GFP_ATOMIC);
-	if (entry) {
-		if (nf_queue_entry_get_refs(entry))
-			return entry;
-		kfree(entry);
-	}
-	return NULL;
+	if (entry)
+		nf_queue_entry_get_refs(entry);
+	return entry;
 }
 
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
@@ -706,7 +703,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	nf_bridge_adjust_skb_data(skb);
 	segs = skb_gso_segment(skb, 0);
 	/* Does not use PTR_ERR to limit the number of error codes that can be
-	 * returned by nf_queue.  For instance, callers rely on -ECANCELED to
+	 * returned by nf_queue.  For instance, callers rely on -ESRCH to
 	 * mean 'ignore this hook'.
 	 */
 	if (IS_ERR_OR_NULL(segs))
-- 
2.1.4
