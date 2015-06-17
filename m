From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 25/43] netfilter: Make nf_hook_ops just a parameter structure
Date: Wed, 17 Jun 2015 10:28:34 -0500
Message-ID: <1434554932-4552-25-git-send-email-ebiederm@xmission.com>
References: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41047 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757429AbbFQPi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:38:28 -0400
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W Biederman <ebiederm@xmission.com>

Add a new structure nf_hook_entry that makes up the nf_hook_lists, and
dynamically allocate it nf_register_hook and free it in
nf_unregister_hook.

This gives the netfilter hook code a little more freedom to evolve
and removes an error case when converting netfilter hooks to be
per nework namespace.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter.h        | 12 +++---
 include/net/netfilter/nf_queue.h |  4 +-
 net/netfilter/core.c             | 92 +++++++++++++++++++++++++---------------
 net/netfilter/nf_internals.h     | 13 +++++-
 net/netfilter/nf_queue.c         |  6 +--
 5 files changed, 80 insertions(+), 47 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 43db9eaf42f6..054cd9d45324 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -84,8 +84,6 @@ typedef unsigned int nf_hookfn(void *priv,
 			       const struct nf_hook_state *state);
 
 struct nf_hook_ops {
-	struct list_head 	list;
-
 	/* User fills in from here down. */
 	nf_hookfn		*hook;
 	struct net_device	*dev;
@@ -122,10 +120,12 @@ struct nf_sockopt_ops {
 };
 
 /* Function to register/unregister hook points. */
-int nf_register_hook(struct net *net, struct nf_hook_ops *reg);
-void nf_unregister_hook(struct net *net, struct nf_hook_ops *reg);
-int nf_register_hooks(struct net *net, struct nf_hook_ops *reg, unsigned int n);
-void nf_unregister_hooks(struct net *net, struct nf_hook_ops *reg, unsigned int n);
+int nf_register_hook(struct net *net, const struct nf_hook_ops *reg);
+void nf_unregister_hook(struct net *net, const struct nf_hook_ops *reg);
+int nf_register_hooks(struct net *net, const struct nf_hook_ops *reg,
+		      unsigned int n);
+void nf_unregister_hooks(struct net *net, const struct nf_hook_ops *reg,
+			 unsigned int n);
 
 /* Functions to register get/setsockopt ranges (non-inclusive).  You
    need to check permissions yourself! */
diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
index d81d584157e1..cad00472e3be 100644
--- a/include/net/netfilter/nf_queue.h
+++ b/include/net/netfilter/nf_queue.h
@@ -5,13 +5,15 @@
 #include <linux/ipv6.h>
 #include <linux/jhash.h>
 
+struct nf_hook_entry;
+
 /* Each queued (to userspace) skbuff has one of these. */
 struct nf_queue_entry {
 	struct list_head	list;
 	struct sk_buff		*skb;
 	unsigned int		id;
 
-	struct nf_hook_ops	*elem;
+	struct nf_hook_entry	*elem;
 	struct nf_hook_state	state;
 	u16			size; /* sizeof(entry) + saved route keys */
 
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index ccf248607342..95456c09cf69 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -59,34 +59,46 @@ EXPORT_SYMBOL(nf_hooks_needed);
 
 static DEFINE_MUTEX(nf_hook_mutex);
 
-int nf_register_hook(struct net *net, struct nf_hook_ops *reg)
+static struct list_head *find_nf_hook_list(struct net *net,
+					   const struct nf_hook_ops *reg)
 {
 	struct list_head *nf_hook_list;
-	struct nf_hook_ops *elem;
 
-	mutex_lock(&nf_hook_mutex);
-	switch (reg->pf) {
-	case NFPROTO_NETDEV:
+	nf_hook_list = &net->nf.hooks[reg->pf][reg->hooknum];
 #ifdef CONFIG_NETFILTER_INGRESS
-		if (reg->hooknum == NF_NETDEV_INGRESS) {
-			BUG_ON(reg->dev == NULL);
-			nf_hook_list = &reg->dev->nf_hooks_ingress;
-			net_inc_ingress_queue();
-			break;
-		}
+	if ((reg->pf == NFPROTO_NETDEV) && (reg->hooknum == NF_NETDEV_INGRESS))
+		nf_hook_list = &reg->dev->nf_hooks_ingress;
 #endif
-		/* Fall through. */
-	default:
-		nf_hook_list = &net->nf.hooks[reg->pf][reg->hooknum];
-		break;
-	}
+	return nf_hook_list;
+}
 
+int nf_register_hook(struct net *net, const struct nf_hook_ops *reg)
+{
+	struct list_head *nf_hook_list;
+	struct nf_hook_entry *elem, *new;
+
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
+
+	new->hook     = reg->hook;
+	new->priv     = reg->priv;
+	new->owner    = reg->owner;
+	new->priority = reg->priority;
+
+	mutex_lock(&nf_hook_mutex);
+	nf_hook_list = find_nf_hook_list(net, reg);
 	list_for_each_entry(elem, nf_hook_list, list) {
-		if (reg->priority < elem->priority)
+		if (new->priority < elem->priority)
 			break;
 	}
-	list_add_rcu(&reg->list, elem->list.prev);
+	list_add_rcu(&new->list, elem->list.prev);
 	mutex_unlock(&nf_hook_mutex);
+
+#ifdef CONFIG_NETFILTER_INGRESS
+	if ((reg->pf == NFPROTO_NETDEV) && (reg->hooknum == NF_NETDEV_INGRESS))
+		net_inc_ingress_queue();
+#endif
 #ifdef HAVE_JUMP_LABEL
 	static_key_slow_inc(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
@@ -94,31 +106,41 @@ int nf_register_hook(struct net *net, struct nf_hook_ops *reg)
 }
 EXPORT_SYMBOL(nf_register_hook);
 
-void nf_unregister_hook(struct net *net, struct nf_hook_ops *reg)
+void nf_unregister_hook(struct net *net, const struct nf_hook_ops *reg)
 {
+	struct list_head *nf_hook_list;
+	struct nf_hook_entry *elem;
+
 	mutex_lock(&nf_hook_mutex);
-	list_del_rcu(&reg->list);
-	mutex_unlock(&nf_hook_mutex);
-	switch (reg->pf) {
-	case NFPROTO_NETDEV:
-#ifdef CONFIG_NETFILTER_INGRESS
-		if (reg->hooknum == NF_NETDEV_INGRESS) {
-			net_dec_ingress_queue();
+	nf_hook_list = find_nf_hook_list(net, reg);
+	list_for_each_entry(elem, nf_hook_list, list) {
+		if ((reg->hook     == elem->hook) &&
+		    (reg->priv     == elem->priv) &&
+		    (reg->owner    == elem->owner) &&
+		    (reg->priority == elem->priority)) {
+			list_del_rcu(&elem->list);
 			break;
 		}
-		break;
-#endif
-	default:
-		break;
 	}
+	mutex_unlock(&nf_hook_mutex);
+	if (&elem->list == nf_hook_list) {
+		WARN(1, "nf_unregister_hook: hook not found!\n");
+		return;
+	}
+#ifdef CONFIG_NETFILTER_INGRESS
+	if ((reg->pf == NFPROTO_NETDEV) && (reg->hooknum == NF_NETDEV_INGRESS))
+		net_dec_ingress_queue();
+#endif
 #ifdef HAVE_JUMP_LABEL
 	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
 	synchronize_net();
+	kfree(elem);
 }
 EXPORT_SYMBOL(nf_unregister_hook);
 
-int nf_register_hooks(struct net *net, struct nf_hook_ops *reg, unsigned int n)
+int nf_register_hooks(struct net *net, const struct nf_hook_ops *reg,
+		      unsigned int n)
 {
 	unsigned int i;
 	int err = 0;
@@ -137,7 +159,7 @@ err:
 }
 EXPORT_SYMBOL(nf_register_hooks);
 
-void nf_unregister_hooks(struct net *net, struct nf_hook_ops *reg,
+void nf_unregister_hooks(struct net *net, const struct nf_hook_ops *reg,
 			 unsigned int n)
 {
 	while (n-- > 0)
@@ -148,7 +170,7 @@ EXPORT_SYMBOL(nf_unregister_hooks);
 unsigned int nf_iterate(struct list_head *head,
 			struct sk_buff *skb,
 			struct nf_hook_state *state,
-			struct nf_hook_ops **elemp)
+			struct nf_hook_entry **elemp)
 {
 	unsigned int verdict;
 
@@ -186,14 +208,14 @@ repeat:
  * -EPERM for NF_DROP, 0 otherwise. */
 int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state)
 {
-	struct nf_hook_ops *elem;
+	struct nf_hook_entry *elem;
 	unsigned int verdict;
 	int ret = 0;
 
 	/* We may already have this, but read-locks nest anyway */
 	rcu_read_lock();
 
-	elem = list_entry_rcu(state->hook_list, struct nf_hook_ops, list);
+	elem = list_entry_rcu(state->hook_list, struct nf_hook_entry, list);
 next_hook:
 	verdict = nf_iterate(state->hook_list, skb, state, &elem);
 	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index ea7f36784b3d..ff8e1f7197dc 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -13,11 +13,20 @@
 
 
 /* core.c */
+struct nf_hook_entry {
+	struct list_head	list;
+	nf_hookfn		*hook;
+	void			*priv;
+	struct module		*owner;
+	/* Hooks are ordered in ascending priority. */
+	int			priority;
+};
+
 unsigned int nf_iterate(struct list_head *head, struct sk_buff *skb,
-			struct nf_hook_state *state, struct nf_hook_ops **elemp);
+			struct nf_hook_state *state, struct nf_hook_entry **elemp);
 
 /* nf_queue.c */
-int nf_queue(struct sk_buff *skb, struct nf_hook_ops *elem,
+int nf_queue(struct sk_buff *skb, struct nf_hook_entry *elem,
 	     struct nf_hook_state *state, unsigned int queuenum);
 int __init netfilter_queue_init(void);
 
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index ab077fe4c1b8..6ae3b2ccceb8 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -110,7 +110,7 @@ EXPORT_SYMBOL_GPL(nf_queue_entry_get_refs);
  * through nf_reinject().
  */
 int nf_queue(struct sk_buff *skb,
-	     struct nf_hook_ops *elem,
+	     struct nf_hook_entry *elem,
 	     struct nf_hook_state *state,
 	     unsigned int queuenum)
 {
@@ -172,7 +172,7 @@ err:
 void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 {
 	struct sk_buff *skb = entry->skb;
-	struct nf_hook_ops *elem = entry->elem;
+	struct nf_hook_entry *elem = entry->elem;
 	const struct nf_afinfo *afinfo;
 	int err;
 
@@ -182,7 +182,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 
 	/* Continue traversal iff userspace said ok... */
 	if (verdict == NF_REPEAT) {
-		elem = list_entry(elem->list.prev, struct nf_hook_ops, list);
+		elem = list_entry(elem->list.prev, struct nf_hook_entry, list);
 		verdict = NF_ACCEPT;
 	}
 
-- 
2.2.1
