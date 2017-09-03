From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/47] netfilter: conntrack: destroy functions need to free queued packets
Date: Mon,  4 Sep 2017 00:27:10 +0200
Message-ID: <1504477667-12130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

queued skbs might be using conntrack extensions that are being removed,
such as timeout.  This happens for skbs that have a skb->nfct in
unconfirmed state (i.e., not in hash table yet).

This is destructive, but there are only two use cases:
 - module removal (rare)
 - netns cleanup (most likely no conntracks exist, and if they do,
   they are removed anyway later on).

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 4 ++++
 net/netfilter/nf_queue.c          | 1 +
 2 files changed, 5 insertions(+)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 80ab4e937765..2bc499186186 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -56,6 +56,8 @@
 #include <net/netfilter/nf_nat_helper.h>
 #include <net/netns/hash.h>
 
+#include "nf_internals.h"
+
 #define NF_CONNTRACK_VERSION	"0.5.0"
 
 int (*nfnetlink_parse_nat_setup_hook)(struct nf_conn *ct,
@@ -1692,6 +1694,7 @@ void nf_ct_unconfirmed_destroy(struct net *net)
 
 	if (atomic_read(&net->ct.count) > 0) {
 		__nf_ct_unconfirmed_destroy(net);
+		nf_queue_nf_hook_drop(net);
 		synchronize_net();
 	}
 }
@@ -1737,6 +1740,7 @@ nf_ct_iterate_destroy(int (*iter)(struct nf_conn *i, void *data), void *data)
 		if (atomic_read(&net->ct.count) == 0)
 			continue;
 		__nf_ct_unconfirmed_destroy(net);
+		nf_queue_nf_hook_drop(net);
 	}
 	rtnl_unlock();
 
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 043850c9d154..4f4d80a58fb5 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -109,6 +109,7 @@ unsigned int nf_queue_nf_hook_drop(struct net *net)
 
 	return count;
 }
+EXPORT_SYMBOL_GPL(nf_queue_nf_hook_drop);
 
 static int __nf_queue(struct sk_buff *skb, const struct nf_hook_state *state,
 		      struct nf_hook_entry *hook_entry, unsigned int queuenum)
-- 
2.1.4


