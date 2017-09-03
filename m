From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 43/47] netfilter: core: batch nf_unregister_net_hooks synchronize_net calls
Date: Mon,  4 Sep 2017 00:42:50 +0200
Message-ID: <1504478574-13281-8-git-send-email-pablo@netfilter.org>
References: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

re-add batching in nf_unregister_net_hooks().

Similar as before, just store an array with to-be-free'd rule arrays
on stack, then call synchronize_net once per batch.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c | 59 +++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 56 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 164ad20d0bd2..04fe25abc5f6 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -395,10 +395,63 @@ EXPORT_SYMBOL(nf_register_net_hooks);
 void nf_unregister_net_hooks(struct net *net, const struct nf_hook_ops *reg,
 			     unsigned int hookcount)
 {
-	unsigned int i;
+	struct nf_hook_entries *to_free[16], *p;
+	struct nf_hook_entries __rcu **pp;
+	unsigned int i, j, n;
+
+	mutex_lock(&nf_hook_mutex);
+	for (i = 0; i < hookcount; i++) {
+		pp = nf_hook_entry_head(net, &reg[i]);
+		if (!pp)
+			continue;
+
+		p = nf_entry_dereference(*pp);
+		if (WARN_ON_ONCE(!p))
+			continue;
+		__nf_unregister_net_hook(p, &reg[i]);
+	}
+	mutex_unlock(&nf_hook_mutex);
+
+	do {
+		n = min_t(unsigned int, hookcount, ARRAY_SIZE(to_free));
+
+		mutex_lock(&nf_hook_mutex);
+
+		for (i = 0, j = 0; i < hookcount && j < n; i++) {
+			pp = nf_hook_entry_head(net, &reg[i]);
+			if (!pp)
+				continue;
+
+			p = nf_entry_dereference(*pp);
+			if (!p)
+				continue;
+
+			to_free[j] = __nf_hook_entries_try_shrink(pp);
+			if (to_free[j])
+				++j;
+		}
+
+		mutex_unlock(&nf_hook_mutex);
+
+		if (j) {
+			unsigned int nfq;
+
+			synchronize_net();
+
+			/* need 2nd synchronize_net() if nfqueue is used, skb
+			 * can get reinjected right before nf_queue_hook_drop()
+			 */
+			nfq = nf_queue_nf_hook_drop(net);
+			if (nfq)
+				synchronize_net();
+
+			for (i = 0; i < j; i++)
+				kvfree(to_free[i]);
+		}
 
-	for (i = 0; i < hookcount; i++)
-		nf_unregister_net_hook(net, &reg[i]);
+		reg += n;
+		hookcount -= n;
+	} while (hookcount > 0);
 }
 EXPORT_SYMBOL(nf_unregister_net_hooks);
 
-- 
2.1.4


