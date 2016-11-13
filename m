From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/39] netfilter: deprecate NF_STOP
Date: Sun, 13 Nov 2016 23:24:58 +0100
Message-ID: <1479075933-4491-5-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NF_STOP is only used by br_netfilter these days, and it can be emulated
with a combination of NF_STOLEN plus explicit call to the ->okfn()
function as Florian suggests.

To retain binary compatibility with userspace nf_queue application, we
have to keep NF_STOP around, so libnetfilter_queue userspace userspace
applications still work if they use NF_STOP for some exotic reason.

Out of tree modules using NF_STOP would break, but we don't care about
those.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter.h  | 2 +-
 net/bridge/br_netfilter_hooks.c | 6 ++++--
 net/netfilter/core.c            | 2 +-
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/netfilter.h b/include/uapi/linux/netfilter.h
index d93f949d1d9a..7550e9176a54 100644
--- a/include/uapi/linux/netfilter.h
+++ b/include/uapi/linux/netfilter.h
@@ -13,7 +13,7 @@
 #define NF_STOLEN 2
 #define NF_QUEUE 3
 #define NF_REPEAT 4
-#define NF_STOP 5
+#define NF_STOP 5	/* Deprecated, for userspace nf_queue compatibility. */
 #define NF_MAX_VERDICT NF_STOP
 
 /* we overload the higher bits for encoding auxiliary data such as the queue
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index d0d66faebe90..7e3645fa6339 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -845,8 +845,10 @@ static unsigned int ip_sabotage_in(void *priv,
 				   struct sk_buff *skb,
 				   const struct nf_hook_state *state)
 {
-	if (skb->nf_bridge && !skb->nf_bridge->in_prerouting)
-		return NF_STOP;
+	if (skb->nf_bridge && !skb->nf_bridge->in_prerouting) {
+		state->okfn(state->net, state->sk, skb);
+		return NF_STOLEN;
+	}
 
 	return NF_ACCEPT;
 }
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index cb0232c11bc8..14f97b624f98 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -333,7 +333,7 @@ int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state)
 	entry = rcu_dereference(state->hook_entries);
 next_hook:
 	verdict = nf_iterate(skb, state, &entry);
-	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
+	if (verdict == NF_ACCEPT) {
 		ret = 1;
 	} else if ((verdict & NF_VERDICT_MASK) == NF_DROP) {
 		kfree_skb(skb);
-- 
2.1.4

