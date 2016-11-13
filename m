From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/39] netfilter: kill NF_HOOK_THRESH() and state->tresh
Date: Sun, 13 Nov 2016 23:24:57 +0100
Message-ID: <1479075933-4491-4-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch c5136b15ea36 ("netfilter: bridge: add and use br_nf_hook_thresh")
introduced br_nf_hook_thresh().

Replace NF_HOOK_THRESH() by br_nf_hook_thresh from
br_nf_forward_finish(), so we have no more callers for this macro.

As a result, state->thresh and explicit thresh parameter in the hook
state structure is not required anymore. And we can get rid of
skip-hook-under-thresh loop in nf_iterate() in the core path that is
only used by br_netfilter to search for the filter hook.

Suggested-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h             | 50 +++++++++--------------------------
 include/linux/netfilter_ingress.h     |  2 +-
 net/bridge/br_netfilter_hooks.c       |  8 +++---
 net/bridge/netfilter/ebtable_broute.c |  2 +-
 net/netfilter/core.c                  |  4 ---
 net/netfilter/nf_queue.c              |  2 --
 6 files changed, 19 insertions(+), 49 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index abc7fdcb9eb1..e0d000f6c9bf 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -49,7 +49,6 @@ struct sock;
 
 struct nf_hook_state {
 	unsigned int hook;
-	int thresh;
 	u_int8_t pf;
 	struct net_device *in;
 	struct net_device *out;
@@ -84,7 +83,7 @@ struct nf_hook_entry {
 static inline void nf_hook_state_init(struct nf_hook_state *p,
 				      struct nf_hook_entry *hook_entry,
 				      unsigned int hook,
-				      int thresh, u_int8_t pf,
+				      u_int8_t pf,
 				      struct net_device *indev,
 				      struct net_device *outdev,
 				      struct sock *sk,
@@ -92,7 +91,6 @@ static inline void nf_hook_state_init(struct nf_hook_state *p,
 				      int (*okfn)(struct net *, struct sock *, struct sk_buff *))
 {
 	p->hook = hook;
-	p->thresh = thresh;
 	p->pf = pf;
 	p->in = indev;
 	p->out = outdev;
@@ -155,20 +153,16 @@ extern struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state);
 
 /**
- *	nf_hook_thresh - call a netfilter hook
+ *	nf_hook - call a netfilter hook
  *
  *	Returns 1 if the hook has allowed the packet to pass.  The function
  *	okfn must be invoked by the caller in this case.  Any other return
  *	value indicates the packet has been consumed by the hook.
  */
-static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
-				 struct net *net,
-				 struct sock *sk,
-				 struct sk_buff *skb,
-				 struct net_device *indev,
-				 struct net_device *outdev,
-				 int (*okfn)(struct net *, struct sock *, struct sk_buff *),
-				 int thresh)
+static inline int nf_hook(u_int8_t pf, unsigned int hook, struct net *net,
+			  struct sock *sk, struct sk_buff *skb,
+			  struct net_device *indev, struct net_device *outdev,
+			  int (*okfn)(struct net *, struct sock *, struct sk_buff *))
 {
 	struct nf_hook_entry *hook_head;
 	int ret = 1;
@@ -185,8 +179,8 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 	if (hook_head) {
 		struct nf_hook_state state;
 
-		nf_hook_state_init(&state, hook_head, hook, thresh,
-				   pf, indev, outdev, sk, net, okfn);
+		nf_hook_state_init(&state, hook_head, hook, pf, indev, outdev,
+				   sk, net, okfn);
 
 		ret = nf_hook_slow(skb, &state);
 	}
@@ -195,14 +189,6 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 	return ret;
 }
 
-static inline int nf_hook(u_int8_t pf, unsigned int hook, struct net *net,
-			  struct sock *sk, struct sk_buff *skb,
-			  struct net_device *indev, struct net_device *outdev,
-			  int (*okfn)(struct net *, struct sock *, struct sk_buff *))
-{
-	return nf_hook_thresh(pf, hook, net, sk, skb, indev, outdev, okfn, INT_MIN);
-}
-                   
 /* Activate hook; either okfn or kfree_skb called, unless a hook
    returns NF_STOLEN (in which case, it's up to the hook to deal with
    the consequences).
@@ -221,19 +207,6 @@ static inline int nf_hook(u_int8_t pf, unsigned int hook, struct net *net,
 */
 
 static inline int
-NF_HOOK_THRESH(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
-	       struct sk_buff *skb, struct net_device *in,
-	       struct net_device *out,
-	       int (*okfn)(struct net *, struct sock *, struct sk_buff *),
-	       int thresh)
-{
-	int ret = nf_hook_thresh(pf, hook, net, sk, skb, in, out, okfn, thresh);
-	if (ret == 1)
-		ret = okfn(net, sk, skb);
-	return ret;
-}
-
-static inline int
 NF_HOOK_COND(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
 	     struct sk_buff *skb, struct net_device *in, struct net_device *out,
 	     int (*okfn)(struct net *, struct sock *, struct sk_buff *),
@@ -242,7 +215,7 @@ NF_HOOK_COND(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
 	int ret;
 
 	if (!cond ||
-	    ((ret = nf_hook_thresh(pf, hook, net, sk, skb, in, out, okfn, INT_MIN)) == 1))
+	    ((ret = nf_hook(pf, hook, net, sk, skb, in, out, okfn)) == 1))
 		ret = okfn(net, sk, skb);
 	return ret;
 }
@@ -252,7 +225,10 @@ NF_HOOK(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk, struct
 	struct net_device *in, struct net_device *out,
 	int (*okfn)(struct net *, struct sock *, struct sk_buff *))
 {
-	return NF_HOOK_THRESH(pf, hook, net, sk, skb, in, out, okfn, INT_MIN);
+	int ret = nf_hook(pf, hook, net, sk, skb, in, out, okfn);
+	if (ret == 1)
+		ret = okfn(net, sk, skb);
+	return ret;
 }
 
 /* Call setsockopt() */
diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
index 33e37fb41d5d..fd44e4131710 100644
--- a/include/linux/netfilter_ingress.h
+++ b/include/linux/netfilter_ingress.h
@@ -26,7 +26,7 @@ static inline int nf_hook_ingress(struct sk_buff *skb)
 	if (unlikely(!e))
 		return 0;
 
-	nf_hook_state_init(&state, e, NF_NETDEV_INGRESS, INT_MIN,
+	nf_hook_state_init(&state, e, NF_NETDEV_INGRESS,
 			   NFPROTO_NETDEV, skb->dev, NULL, NULL,
 			   dev_net(skb->dev), NULL);
 	return nf_hook_slow(skb, &state);
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 2fe9345c1407..d0d66faebe90 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -561,8 +561,8 @@ static int br_nf_forward_finish(struct net *net, struct sock *sk, struct sk_buff
 	}
 	nf_bridge_push_encap_header(skb);
 
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, net, sk, skb,
-		       in, skb->dev, br_forward_finish, 1);
+	br_nf_hook_thresh(NF_BR_FORWARD, net, sk, skb, in, skb->dev,
+			  br_forward_finish);
 	return 0;
 }
 
@@ -1016,8 +1016,8 @@ int br_nf_hook_thresh(unsigned int hook, struct net *net,
 
 	/* We may already have this, but read-locks nest anyway */
 	rcu_read_lock();
-	nf_hook_state_init(&state, elem, hook, NF_BR_PRI_BRNF + 1,
-			   NFPROTO_BRIDGE, indev, outdev, sk, net, okfn);
+	nf_hook_state_init(&state, elem, hook, NFPROTO_BRIDGE, indev, outdev,
+			   sk, net, okfn);
 
 	ret = nf_hook_slow(skb, &state);
 	rcu_read_unlock();
diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index ec94c6f1ae88..599679e3498d 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -53,7 +53,7 @@ static int ebt_broute(struct sk_buff *skb)
 	struct nf_hook_state state;
 	int ret;
 
-	nf_hook_state_init(&state, NULL, NF_BR_BROUTING, INT_MIN,
+	nf_hook_state_init(&state, NULL, NF_BR_BROUTING,
 			   NFPROTO_BRIDGE, skb->dev, NULL, NULL,
 			   dev_net(skb->dev), NULL);
 
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 76014ad72ec5..cb0232c11bc8 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -309,10 +309,6 @@ unsigned int nf_iterate(struct sk_buff *skb,
 	unsigned int verdict;
 
 	while (*entryp) {
-		if (state->thresh > (*entryp)->ops.priority) {
-			*entryp = rcu_dereference((*entryp)->next);
-			continue;
-		}
 repeat:
 		verdict = (*entryp)->ops.hook((*entryp)->ops.priv, skb, state);
 		if (verdict != NF_ACCEPT) {
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 8f08d759844a..0fb38966e5bf 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -200,8 +200,6 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 			verdict = NF_DROP;
 	}
 
-	entry->state.thresh = INT_MIN;
-
 	if (verdict == NF_ACCEPT) {
 		hook_entry = rcu_dereference(hook_entry->next);
 		if (hook_entry)
-- 
2.1.4

