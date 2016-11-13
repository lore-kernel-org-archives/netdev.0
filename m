From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/39] netfilter: remove hook_entries field from nf_hook_state
Date: Sun, 13 Nov 2016 23:25:02 +0100
Message-ID: <1479075933-4491-9-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This field is only useful for nf_queue, so store it in the
nf_queue_entry structure instead, away from the core path. Pass
hook_head to nf_hook_slow().

Since we always have a valid entry on the first iteration in
nf_iterate(), we can use 'do { ... } while (entry)' loop instead.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h             | 10 ++++------
 include/linux/netfilter_ingress.h     |  4 ++--
 include/net/netfilter/nf_queue.h      |  1 +
 net/bridge/br_netfilter_hooks.c       |  4 ++--
 net/bridge/netfilter/ebtable_broute.c |  2 +-
 net/netfilter/core.c                  |  9 ++++-----
 net/netfilter/nf_queue.c              | 13 +++++--------
 net/netfilter/nfnetlink_queue.c       |  2 +-
 8 files changed, 20 insertions(+), 25 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index e0d000f6c9bf..69230140215b 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -54,7 +54,6 @@ struct nf_hook_state {
 	struct net_device *out;
 	struct sock *sk;
 	struct net *net;
-	struct nf_hook_entry __rcu *hook_entries;
 	int (*okfn)(struct net *, struct sock *, struct sk_buff *);
 };
 
@@ -81,7 +80,6 @@ struct nf_hook_entry {
 };
 
 static inline void nf_hook_state_init(struct nf_hook_state *p,
-				      struct nf_hook_entry *hook_entry,
 				      unsigned int hook,
 				      u_int8_t pf,
 				      struct net_device *indev,
@@ -96,7 +94,6 @@ static inline void nf_hook_state_init(struct nf_hook_state *p,
 	p->out = outdev;
 	p->sk = sk;
 	p->net = net;
-	RCU_INIT_POINTER(p->hook_entries, hook_entry);
 	p->okfn = okfn;
 }
 
@@ -150,7 +147,8 @@ void nf_unregister_sockopt(struct nf_sockopt_ops *reg);
 extern struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 #endif
 
-int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state);
+int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state,
+		 struct nf_hook_entry *entry);
 
 /**
  *	nf_hook - call a netfilter hook
@@ -179,10 +177,10 @@ static inline int nf_hook(u_int8_t pf, unsigned int hook, struct net *net,
 	if (hook_head) {
 		struct nf_hook_state state;
 
-		nf_hook_state_init(&state, hook_head, hook, pf, indev, outdev,
+		nf_hook_state_init(&state, hook, pf, indev, outdev,
 				   sk, net, okfn);
 
-		ret = nf_hook_slow(skb, &state);
+		ret = nf_hook_slow(skb, &state, hook_head);
 	}
 	rcu_read_unlock();
 
diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
index fd44e4131710..2dc3b49b804a 100644
--- a/include/linux/netfilter_ingress.h
+++ b/include/linux/netfilter_ingress.h
@@ -26,10 +26,10 @@ static inline int nf_hook_ingress(struct sk_buff *skb)
 	if (unlikely(!e))
 		return 0;
 
-	nf_hook_state_init(&state, e, NF_NETDEV_INGRESS,
+	nf_hook_state_init(&state, NF_NETDEV_INGRESS,
 			   NFPROTO_NETDEV, skb->dev, NULL, NULL,
 			   dev_net(skb->dev), NULL);
-	return nf_hook_slow(skb, &state);
+	return nf_hook_slow(skb, &state, e);
 }
 
 static inline void nf_hook_ingress_init(struct net_device *dev)
diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
index 2280cfe86c56..09948d10e38e 100644
--- a/include/net/netfilter/nf_queue.h
+++ b/include/net/netfilter/nf_queue.h
@@ -12,6 +12,7 @@ struct nf_queue_entry {
 	unsigned int		id;
 
 	struct nf_hook_state	state;
+	struct nf_hook_entry	*hook;
 	u16			size; /* sizeof(entry) + saved route keys */
 
 	/* extra space to store route keys */
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 7e3645fa6339..8155bd2a5138 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -1018,10 +1018,10 @@ int br_nf_hook_thresh(unsigned int hook, struct net *net,
 
 	/* We may already have this, but read-locks nest anyway */
 	rcu_read_lock();
-	nf_hook_state_init(&state, elem, hook, NFPROTO_BRIDGE, indev, outdev,
+	nf_hook_state_init(&state, hook, NFPROTO_BRIDGE, indev, outdev,
 			   sk, net, okfn);
 
-	ret = nf_hook_slow(skb, &state);
+	ret = nf_hook_slow(skb, &state, elem);
 	rcu_read_unlock();
 	if (ret == 1)
 		ret = okfn(net, sk, skb);
diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index 599679e3498d..8fe36dc3aab2 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -53,7 +53,7 @@ static int ebt_broute(struct sk_buff *skb)
 	struct nf_hook_state state;
 	int ret;
 
-	nf_hook_state_init(&state, NULL, NF_BR_BROUTING,
+	nf_hook_state_init(&state, NF_BR_BROUTING,
 			   NFPROTO_BRIDGE, skb->dev, NULL, NULL,
 			   dev_net(skb->dev), NULL);
 
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 64623374bc5f..ebece48b8392 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -308,7 +308,7 @@ unsigned int nf_iterate(struct sk_buff *skb,
 {
 	unsigned int verdict;
 
-	while (*entryp) {
+	do {
 repeat:
 		verdict = (*entryp)->ops.hook((*entryp)->ops.priv, skb, state);
 		if (verdict != NF_ACCEPT) {
@@ -317,20 +317,19 @@ unsigned int nf_iterate(struct sk_buff *skb,
 			goto repeat;
 		}
 		*entryp = rcu_dereference((*entryp)->next);
-	}
+	} while (*entryp);
 	return NF_ACCEPT;
 }
 
 
 /* Returns 1 if okfn() needs to be executed by the caller,
  * -EPERM for NF_DROP, 0 otherwise.  Caller must hold rcu_read_lock. */
-int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state)
+int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state,
+		 struct nf_hook_entry *entry)
 {
-	struct nf_hook_entry *entry;
 	unsigned int verdict;
 	int ret;
 
-	entry = rcu_dereference(state->hook_entries);
 next_hook:
 	verdict = nf_iterate(skb, state, &entry);
 	switch (verdict & NF_VERDICT_MASK) {
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 0fb38966e5bf..2e39e38ae1c7 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -108,7 +108,7 @@ void nf_queue_nf_hook_drop(struct net *net, const struct nf_hook_entry *entry)
 }
 
 static int __nf_queue(struct sk_buff *skb, const struct nf_hook_state *state,
-		      unsigned int queuenum)
+		      struct nf_hook_entry *hook_entry, unsigned int queuenum)
 {
 	int status = -ENOENT;
 	struct nf_queue_entry *entry = NULL;
@@ -136,6 +136,7 @@ static int __nf_queue(struct sk_buff *skb, const struct nf_hook_state *state,
 	*entry = (struct nf_queue_entry) {
 		.skb	= skb,
 		.state	= *state,
+		.hook	= hook_entry,
 		.size	= sizeof(*entry) + afinfo->route_key_size,
 	};
 
@@ -163,8 +164,7 @@ int nf_queue(struct sk_buff *skb, struct nf_hook_state *state,
 	struct nf_hook_entry *entry = *entryp;
 	int ret;
 
-	RCU_INIT_POINTER(state->hook_entries, entry);
-	ret = __nf_queue(skb, state, verdict >> NF_VERDICT_QBITS);
+	ret = __nf_queue(skb, state, entry, verdict >> NF_VERDICT_QBITS);
 	if (ret < 0) {
 		if (ret == -ESRCH &&
 		    (verdict & NF_VERDICT_FLAG_QUEUE_BYPASS)) {
@@ -179,15 +179,12 @@ int nf_queue(struct sk_buff *skb, struct nf_hook_state *state,
 
 void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 {
-	struct nf_hook_entry *hook_entry;
+	struct nf_hook_entry *hook_entry = entry->hook;
+	struct nf_hook_ops *elem = &hook_entry->ops;
 	struct sk_buff *skb = entry->skb;
 	const struct nf_afinfo *afinfo;
-	struct nf_hook_ops *elem;
 	int err;
 
-	hook_entry = rcu_dereference(entry->state.hook_entries);
-	elem = &hook_entry->ops;
-
 	nf_queue_entry_release_refs(entry);
 
 	/* Continue traversal iff userspace said ok... */
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 5379f788a372..1e33115b399f 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -919,7 +919,7 @@ static struct notifier_block nfqnl_dev_notifier = {
 
 static int nf_hook_cmp(struct nf_queue_entry *entry, unsigned long entry_ptr)
 {
-	return rcu_access_pointer(entry->state.hook_entries) ==
+	return rcu_access_pointer(entry->hook) ==
 		(struct nf_hook_entry *)entry_ptr;
 }
 
-- 
2.1.4

