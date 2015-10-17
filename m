From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 29/35] netfilter: nf_queue: remove rcu_read_lock calls
Date: Sat, 17 Oct 2015 13:33:04 +0200
Message-ID: <1445081590-2924-30-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

All verdict handlers make use of the nfnetlink .call_rcu callback
so rcu readlock is already held.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_queue.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index efc9688..5baa8e2 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -124,22 +124,20 @@ int nf_queue(struct sk_buff *skb,
 	const struct nf_queue_handler *qh;
 
 	/* QUEUE == DROP if no one is waiting, to be safe. */
-	rcu_read_lock();
-
 	qh = rcu_dereference(queue_handler);
 	if (!qh) {
 		status = -ESRCH;
-		goto err_unlock;
+		goto err;
 	}
 
 	afinfo = nf_get_afinfo(state->pf);
 	if (!afinfo)
-		goto err_unlock;
+		goto err;
 
 	entry = kmalloc(sizeof(*entry) + afinfo->route_key_size, GFP_ATOMIC);
 	if (!entry) {
 		status = -ENOMEM;
-		goto err_unlock;
+		goto err;
 	}
 
 	*entry = (struct nf_queue_entry) {
@@ -154,8 +152,6 @@ int nf_queue(struct sk_buff *skb,
 	afinfo->saveroute(skb, entry);
 	status = qh->outfn(entry, queuenum);
 
-	rcu_read_unlock();
-
 	if (status < 0) {
 		nf_queue_entry_release_refs(entry);
 		goto err;
@@ -163,8 +159,6 @@ int nf_queue(struct sk_buff *skb,
 
 	return 0;
 
-err_unlock:
-	rcu_read_unlock();
 err:
 	kfree(entry);
 	return status;
@@ -177,8 +171,6 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 	const struct nf_afinfo *afinfo;
 	int err;
 
-	rcu_read_lock();
-
 	nf_queue_entry_release_refs(entry);
 
 	/* Continue traversal iff userspace said ok... */
@@ -221,7 +213,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 	default:
 		kfree_skb(skb);
 	}
-	rcu_read_unlock();
+
 	kfree(entry);
 }
 EXPORT_SYMBOL(nf_reinject);
-- 
2.1.4

