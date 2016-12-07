From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/50] netfilter: introduce accessor functions for hook entries
Date: Wed,  7 Dec 2016 22:52:26 +0100
Message-ID: <1481147576-5690-21-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60234 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933365AbcLGVxm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:42 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 1E2C9B6C79
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:36 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0F1D7DA85F
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:36 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D2E58DA85F
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:33 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>

This allows easier future refactoring.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h       | 27 +++++++++++++++++++++++++++
 net/bridge/br_netfilter_hooks.c |  2 +-
 net/netfilter/core.c            | 10 ++++------
 net/netfilter/nf_queue.c        |  5 ++---
 4 files changed, 34 insertions(+), 10 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 69230140215b..575aa198097e 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -79,6 +79,33 @@ struct nf_hook_entry {
 	const struct nf_hook_ops	*orig_ops;
 };
 
+static inline void
+nf_hook_entry_init(struct nf_hook_entry *entry,	const struct nf_hook_ops *ops)
+{
+	entry->next = NULL;
+	entry->ops = *ops;
+	entry->orig_ops = ops;
+}
+
+static inline int
+nf_hook_entry_priority(const struct nf_hook_entry *entry)
+{
+	return entry->ops.priority;
+}
+
+static inline int
+nf_hook_entry_hookfn(const struct nf_hook_entry *entry, struct sk_buff *skb,
+		     struct nf_hook_state *state)
+{
+	return entry->ops.hook(entry->ops.priv, skb, state);
+}
+
+static inline const struct nf_hook_ops *
+nf_hook_entry_ops(const struct nf_hook_entry *entry)
+{
+	return entry->orig_ops;
+}
+
 static inline void nf_hook_state_init(struct nf_hook_state *p,
 				      unsigned int hook,
 				      u_int8_t pf,
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 83d937f4415e..adad2eed29e6 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -1010,7 +1010,7 @@ int br_nf_hook_thresh(unsigned int hook, struct net *net,
 
 	elem = rcu_dereference(net->nf.hooks[NFPROTO_BRIDGE][hook]);
 
-	while (elem && (elem->ops.priority <= NF_BR_PRI_BRNF))
+	while (elem && (nf_hook_entry_priority(elem) <= NF_BR_PRI_BRNF))
 		elem = rcu_dereference(elem->next);
 
 	if (!elem)
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index de30e08d58f2..2bb46e2d8d30 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -102,15 +102,13 @@ int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
 	if (!entry)
 		return -ENOMEM;
 
-	entry->orig_ops	= reg;
-	entry->ops	= *reg;
-	entry->next	= NULL;
+	nf_hook_entry_init(entry, reg);
 
 	mutex_lock(&nf_hook_mutex);
 
 	/* Find the spot in the list */
 	while ((p = nf_entry_dereference(*pp)) != NULL) {
-		if (reg->priority < p->orig_ops->priority)
+		if (reg->priority < nf_hook_entry_priority(p))
 			break;
 		pp = &p->next;
 	}
@@ -140,7 +138,7 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 
 	mutex_lock(&nf_hook_mutex);
 	while ((p = nf_entry_dereference(*pp)) != NULL) {
-		if (p->orig_ops == reg) {
+		if (nf_hook_entry_ops(p) == reg) {
 			rcu_assign_pointer(*pp, p->next);
 			break;
 		}
@@ -311,7 +309,7 @@ int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state,
 	int ret;
 
 	do {
-		verdict = entry->ops.hook(entry->ops.priv, skb, state);
+		verdict = nf_hook_entry_hookfn(entry, skb, state);
 		switch (verdict & NF_VERDICT_MASK) {
 		case NF_ACCEPT:
 			entry = rcu_dereference(entry->next);
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 77cba9f6ccb6..4a7662486f44 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -185,7 +185,7 @@ static unsigned int nf_iterate(struct sk_buff *skb,
 
 	do {
 repeat:
-		verdict = (*entryp)->ops.hook((*entryp)->ops.priv, skb, state);
+		verdict = nf_hook_entry_hookfn((*entryp), skb, state);
 		if (verdict != NF_ACCEPT) {
 			if (verdict != NF_REPEAT)
 				return verdict;
@@ -200,7 +200,6 @@ static unsigned int nf_iterate(struct sk_buff *skb,
 void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 {
 	struct nf_hook_entry *hook_entry = entry->hook;
-	struct nf_hook_ops *elem = &hook_entry->ops;
 	struct sk_buff *skb = entry->skb;
 	const struct nf_afinfo *afinfo;
 	int err;
@@ -209,7 +208,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 
 	/* Continue traversal iff userspace said ok... */
 	if (verdict == NF_REPEAT)
-		verdict = elem->hook(elem->priv, skb, &entry->state);
+		verdict = nf_hook_entry_hookfn(hook_entry, skb, &entry->state);
 
 	if (verdict == NF_ACCEPT) {
 		afinfo = nf_get_afinfo(entry->state.pf);
-- 
2.1.4
