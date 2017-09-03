From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 41/47] netfilter: convert hook list to an array
Date: Mon,  4 Sep 2017 00:42:48 +0200
Message-ID: <1504478574-13281-6-git-send-email-pablo@netfilter.org>
References: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aaron Conole <aconole@bytheb.org>

This converts the storage and layout of netfilter hook entries from a
linked list to an array.  After this commit, hook entries will be
stored adjacent in memory.  The next pointer is no longer required.

The ops pointers are stored at the end of the array as they are only
used in the register/unregister path and in the legacy br_netfilter code.

nf_unregister_net_hooks() is slower than needed as it just calls
nf_unregister_net_hook in a loop (i.e. at least n synchronize_net()
calls), this will be addressed in followup patch.

Test setup:
 - ixgbe 10gbit
 - netperf UDP_STREAM, 64 byte packets
 - 5 hooks: (raw + mangle prerouting, mangle+filter input, inet filter):
empty mangle and raw prerouting, mangle and filter input hooks:
353.9
this patch:
364.2

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netdevice.h         |   2 +-
 include/linux/netfilter.h         |  45 +++---
 include/linux/netfilter_ingress.h |   4 +-
 include/net/netfilter/nf_queue.h  |   2 +-
 include/net/netns/netfilter.h     |   2 +-
 net/bridge/br_netfilter_hooks.c   |  19 ++-
 net/netfilter/core.c              | 297 ++++++++++++++++++++++++++++----------
 net/netfilter/nf_internals.h      |   3 +-
 net/netfilter/nf_queue.c          |  67 +++++----
 9 files changed, 307 insertions(+), 134 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 614642eb7eb7..ca0a30127300 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1811,7 +1811,7 @@ struct net_device {
 #endif
 	struct netdev_queue __rcu *ingress_queue;
 #ifdef CONFIG_NETFILTER_INGRESS
-	struct nf_hook_entry __rcu *nf_hooks_ingress;
+	struct nf_hook_entries __rcu *nf_hooks_ingress;
 #endif
 
 	unsigned char		broadcast[MAX_ADDR_LEN];
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 22f081065d49..f84bca1703cd 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -72,25 +72,32 @@ struct nf_hook_ops {
 };
 
 struct nf_hook_entry {
-	struct nf_hook_entry __rcu	*next;
 	nf_hookfn			*hook;
 	void				*priv;
-	const struct nf_hook_ops	*orig_ops;
 };
 
-static inline void
-nf_hook_entry_init(struct nf_hook_entry *entry,	const struct nf_hook_ops *ops)
-{
-	entry->next = NULL;
-	entry->hook = ops->hook;
-	entry->priv = ops->priv;
-	entry->orig_ops = ops;
-}
+struct nf_hook_entries {
+	u16				num_hook_entries;
+	/* padding */
+	struct nf_hook_entry		hooks[];
+
+	/* trailer: pointers to original orig_ops of each hook.
+	 *
+	 * This is not part of struct nf_hook_entry since its only
+	 * needed in slow path (hook register/unregister).
+	 *
+	 * const struct nf_hook_ops     *orig_ops[]
+	 */
+};
 
-static inline int
-nf_hook_entry_priority(const struct nf_hook_entry *entry)
+static inline struct nf_hook_ops **nf_hook_entries_get_hook_ops(const struct nf_hook_entries *e)
 {
-	return entry->orig_ops->priority;
+	unsigned int n = e->num_hook_entries;
+	const void *hook_end;
+
+	hook_end = &e->hooks[n]; /* this is *past* ->hooks[]! */
+
+	return (struct nf_hook_ops **)hook_end;
 }
 
 static inline int
@@ -100,12 +107,6 @@ nf_hook_entry_hookfn(const struct nf_hook_entry *entry, struct sk_buff *skb,
 	return entry->hook(entry->priv, skb, state);
 }
 
-static inline const struct nf_hook_ops *
-nf_hook_entry_ops(const struct nf_hook_entry *entry)
-{
-	return entry->orig_ops;
-}
-
 static inline void nf_hook_state_init(struct nf_hook_state *p,
 				      unsigned int hook,
 				      u_int8_t pf,
@@ -168,7 +169,7 @@ extern struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 #endif
 
 int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state,
-		 struct nf_hook_entry *entry);
+		 const struct nf_hook_entries *e, unsigned int i);
 
 /**
  *	nf_hook - call a netfilter hook
@@ -182,7 +183,7 @@ static inline int nf_hook(u_int8_t pf, unsigned int hook, struct net *net,
 			  struct net_device *indev, struct net_device *outdev,
 			  int (*okfn)(struct net *, struct sock *, struct sk_buff *))
 {
-	struct nf_hook_entry *hook_head;
+	struct nf_hook_entries *hook_head;
 	int ret = 1;
 
 #ifdef HAVE_JUMP_LABEL
@@ -200,7 +201,7 @@ static inline int nf_hook(u_int8_t pf, unsigned int hook, struct net *net,
 		nf_hook_state_init(&state, hook, pf, indev, outdev,
 				   sk, net, okfn);
 
-		ret = nf_hook_slow(skb, &state, hook_head);
+		ret = nf_hook_slow(skb, &state, hook_head, 0);
 	}
 	rcu_read_unlock();
 
diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
index 59476061de86..8d5dae1e2ff8 100644
--- a/include/linux/netfilter_ingress.h
+++ b/include/linux/netfilter_ingress.h
@@ -17,7 +17,7 @@ static inline bool nf_hook_ingress_active(const struct sk_buff *skb)
 /* caller must hold rcu_read_lock */
 static inline int nf_hook_ingress(struct sk_buff *skb)
 {
-	struct nf_hook_entry *e = rcu_dereference(skb->dev->nf_hooks_ingress);
+	struct nf_hook_entries *e = rcu_dereference(skb->dev->nf_hooks_ingress);
 	struct nf_hook_state state;
 	int ret;
 
@@ -30,7 +30,7 @@ static inline int nf_hook_ingress(struct sk_buff *skb)
 	nf_hook_state_init(&state, NF_NETDEV_INGRESS,
 			   NFPROTO_NETDEV, skb->dev, NULL, NULL,
 			   dev_net(skb->dev), NULL);
-	ret = nf_hook_slow(skb, &state, e);
+	ret = nf_hook_slow(skb, &state, e, 0);
 	if (ret == 0)
 		return -1;
 
diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
index 4454719ff849..39468720fc19 100644
--- a/include/net/netfilter/nf_queue.h
+++ b/include/net/netfilter/nf_queue.h
@@ -10,9 +10,9 @@ struct nf_queue_entry {
 	struct list_head	list;
 	struct sk_buff		*skb;
 	unsigned int		id;
+	unsigned int		hook_index;	/* index in hook_entries->hook[] */
 
 	struct nf_hook_state	state;
-	struct nf_hook_entry	*hook;
 	u16			size; /* sizeof(entry) + saved route keys */
 
 	/* extra space to store route keys */
diff --git a/include/net/netns/netfilter.h b/include/net/netns/netfilter.h
index cea396b53a60..72d66c8763d0 100644
--- a/include/net/netns/netfilter.h
+++ b/include/net/netns/netfilter.h
@@ -16,7 +16,7 @@ struct netns_nf {
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header *nf_log_dir_header;
 #endif
-	struct nf_hook_entry __rcu *hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
+	struct nf_hook_entries __rcu *hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
 	bool			defrag_ipv4;
 #endif
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 626f4b2cef16..c2eea1b8737a 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -985,22 +985,25 @@ int br_nf_hook_thresh(unsigned int hook, struct net *net,
 		      int (*okfn)(struct net *, struct sock *,
 				  struct sk_buff *))
 {
-	struct nf_hook_entry *elem;
+	const struct nf_hook_entries *e;
 	struct nf_hook_state state;
+	struct nf_hook_ops **ops;
+	unsigned int i;
 	int ret;
 
-	for (elem = rcu_dereference(net->nf.hooks[NFPROTO_BRIDGE][hook]);
-	     elem && nf_hook_entry_priority(elem) <= NF_BR_PRI_BRNF;
-	     elem = rcu_dereference(elem->next))
-		;
-
-	if (!elem)
+	e = rcu_dereference(net->nf.hooks[NFPROTO_BRIDGE][hook]);
+	if (!e)
 		return okfn(net, sk, skb);
 
+	ops = nf_hook_entries_get_hook_ops(e);
+	for (i = 0; i < e->num_hook_entries &&
+	      ops[i]->priority <= NF_BR_PRI_BRNF; i++)
+		;
+
 	nf_hook_state_init(&state, hook, NFPROTO_BRIDGE, indev, outdev,
 			   sk, net, okfn);
 
-	ret = nf_hook_slow(skb, &state, elem);
+	ret = nf_hook_slow(skb, &state, e, i);
 	if (ret == 1)
 		ret = okfn(net, sk, skb);
 
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 974cf2a3795a..1a9e23c9ab98 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -21,7 +21,7 @@
 #include <linux/inetdevice.h>
 #include <linux/proc_fs.h>
 #include <linux/mutex.h>
-#include <linux/slab.h>
+#include <linux/mm.h>
 #include <linux/rcupdate.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -62,10 +62,160 @@ EXPORT_SYMBOL(nf_hooks_needed);
 #endif
 
 static DEFINE_MUTEX(nf_hook_mutex);
+
+/* max hooks per family/hooknum */
+#define MAX_HOOK_COUNT		1024
+
 #define nf_entry_dereference(e) \
 	rcu_dereference_protected(e, lockdep_is_held(&nf_hook_mutex))
 
-static struct nf_hook_entry __rcu **nf_hook_entry_head(struct net *net, const struct nf_hook_ops *reg)
+static struct nf_hook_entries *allocate_hook_entries_size(u16 num)
+{
+	struct nf_hook_entries *e;
+	size_t alloc = sizeof(*e) +
+		       sizeof(struct nf_hook_entry) * num +
+		       sizeof(struct nf_hook_ops *) * num;
+
+	if (num == 0)
+		return NULL;
+
+	e = kvzalloc(alloc, GFP_KERNEL);
+	if (e)
+		e->num_hook_entries = num;
+	return e;
+}
+
+static unsigned int accept_all(void *priv,
+			       struct sk_buff *skb,
+			       const struct nf_hook_state *state)
+{
+	return NF_ACCEPT; /* ACCEPT makes nf_hook_slow call next hook */
+}
+
+static const struct nf_hook_ops dummy_ops = {
+	.hook = accept_all,
+	.priority = INT_MIN,
+};
+
+static struct nf_hook_entries *
+nf_hook_entries_grow(const struct nf_hook_entries *old,
+		     const struct nf_hook_ops *reg)
+{
+	unsigned int i, alloc_entries, nhooks, old_entries;
+	struct nf_hook_ops **orig_ops = NULL;
+	struct nf_hook_ops **new_ops;
+	struct nf_hook_entries *new;
+	bool inserted = false;
+
+	alloc_entries = 1;
+	old_entries = old ? old->num_hook_entries : 0;
+
+	if (old) {
+		orig_ops = nf_hook_entries_get_hook_ops(old);
+
+		for (i = 0; i < old_entries; i++) {
+			if (orig_ops[i] != &dummy_ops)
+				alloc_entries++;
+		}
+	}
+
+	if (alloc_entries > MAX_HOOK_COUNT)
+		return ERR_PTR(-E2BIG);
+
+	new = allocate_hook_entries_size(alloc_entries);
+	if (!new)
+		return ERR_PTR(-ENOMEM);
+
+	new_ops = nf_hook_entries_get_hook_ops(new);
+
+	i = 0;
+	nhooks = 0;
+	while (i < old_entries) {
+		if (orig_ops[i] == &dummy_ops) {
+			++i;
+			continue;
+		}
+		if (inserted || reg->priority > orig_ops[i]->priority) {
+			new_ops[nhooks] = (void *)orig_ops[i];
+			new->hooks[nhooks] = old->hooks[i];
+			i++;
+		} else {
+			new_ops[nhooks] = (void *)reg;
+			new->hooks[nhooks].hook = reg->hook;
+			new->hooks[nhooks].priv = reg->priv;
+			inserted = true;
+		}
+		nhooks++;
+	}
+
+	if (!inserted) {
+		new_ops[nhooks] = (void *)reg;
+		new->hooks[nhooks].hook = reg->hook;
+		new->hooks[nhooks].priv = reg->priv;
+	}
+
+	return new;
+}
+
+/*
+ * __nf_hook_entries_try_shrink - try to shrink hook array
+ *
+ * @pp -- location of hook blob
+ *
+ * Hook unregistration must always succeed, so to-be-removed hooks
+ * are replaced by a dummy one that will just move to next hook.
+ *
+ * This counts the current dummy hooks, attempts to allocate new blob,
+ * copies the live hooks, then replaces and discards old one.
+ *
+ * return values:
+ *
+ * Returns address to free, or NULL.
+ */
+static void *__nf_hook_entries_try_shrink(struct nf_hook_entries __rcu **pp)
+{
+	struct nf_hook_entries *old, *new = NULL;
+	unsigned int i, j, skip = 0, hook_entries;
+	struct nf_hook_ops **orig_ops;
+	struct nf_hook_ops **new_ops;
+
+	old = nf_entry_dereference(*pp);
+	if (WARN_ON_ONCE(!old))
+		return NULL;
+
+	orig_ops = nf_hook_entries_get_hook_ops(old);
+	for (i = 0; i < old->num_hook_entries; i++) {
+		if (orig_ops[i] == &dummy_ops)
+			skip++;
+	}
+
+	/* if skip == hook_entries all hooks have been removed */
+	hook_entries = old->num_hook_entries;
+	if (skip == hook_entries)
+		goto out_assign;
+
+	if (WARN_ON(skip == 0))
+		return NULL;
+
+	hook_entries -= skip;
+	new = allocate_hook_entries_size(hook_entries);
+	if (!new)
+		return NULL;
+
+	new_ops = nf_hook_entries_get_hook_ops(new);
+	for (i = 0, j = 0; i < old->num_hook_entries; i++) {
+		if (orig_ops[i] == &dummy_ops)
+			continue;
+		new->hooks[j] = old->hooks[i];
+		new_ops[j] = (void *)orig_ops[i];
+		j++;
+	}
+out_assign:
+	rcu_assign_pointer(*pp, new);
+	return old;
+}
+
+static struct nf_hook_entries __rcu **nf_hook_entry_head(struct net *net, const struct nf_hook_ops *reg)
 {
 	if (reg->pf != NFPROTO_NETDEV)
 		return net->nf.hooks[reg->pf]+reg->hooknum;
@@ -76,13 +226,14 @@ static struct nf_hook_entry __rcu **nf_hook_entry_head(struct net *net, const st
 			return &reg->dev->nf_hooks_ingress;
 	}
 #endif
+	WARN_ON_ONCE(1);
 	return NULL;
 }
 
 int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
 {
-	struct nf_hook_entry __rcu **pp;
-	struct nf_hook_entry *entry, *p;
+	struct nf_hook_entries *p, *new_hooks;
+	struct nf_hook_entries __rcu **pp;
 
 	if (reg->pf == NFPROTO_NETDEV) {
 #ifndef CONFIG_NETFILTER_INGRESS
@@ -98,23 +249,18 @@ int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
 	if (!pp)
 		return -EINVAL;
 
-	entry = kmalloc(sizeof(*entry), GFP_KERNEL);
-	if (!entry)
-		return -ENOMEM;
-
-	nf_hook_entry_init(entry, reg);
-
 	mutex_lock(&nf_hook_mutex);
 
-	/* Find the spot in the list */
-	for (; (p = nf_entry_dereference(*pp)) != NULL; pp = &p->next) {
-		if (reg->priority < nf_hook_entry_priority(p))
-			break;
-	}
-	rcu_assign_pointer(entry->next, p);
-	rcu_assign_pointer(*pp, entry);
+	p = nf_entry_dereference(*pp);
+	new_hooks = nf_hook_entries_grow(p, reg);
+
+	if (!IS_ERR(new_hooks))
+		rcu_assign_pointer(*pp, new_hooks);
 
 	mutex_unlock(&nf_hook_mutex);
+	if (IS_ERR(new_hooks))
+		return PTR_ERR(new_hooks);
+
 #ifdef CONFIG_NETFILTER_INGRESS
 	if (reg->pf == NFPROTO_NETDEV && reg->hooknum == NF_NETDEV_INGRESS)
 		net_inc_ingress_queue();
@@ -122,48 +268,74 @@ int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
 #ifdef HAVE_JUMP_LABEL
 	static_key_slow_inc(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
+	synchronize_net();
+	BUG_ON(p == new_hooks);
+	kvfree(p);
 	return 0;
 }
 EXPORT_SYMBOL(nf_register_net_hook);
 
-static struct nf_hook_entry *
-__nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
+/*
+ * __nf_unregister_net_hook - remove a hook from blob
+ *
+ * @oldp: current address of hook blob
+ * @unreg: hook to unregister
+ *
+ * This cannot fail, hook unregistration must always succeed.
+ * Therefore replace the to-be-removed hook with a dummy hook.
+ */
+static void __nf_unregister_net_hook(struct nf_hook_entries *old,
+				     const struct nf_hook_ops *unreg)
 {
-	struct nf_hook_entry __rcu **pp;
-	struct nf_hook_entry *p;
-
-	pp = nf_hook_entry_head(net, reg);
-	if (WARN_ON_ONCE(!pp))
-		return NULL;
+	struct nf_hook_ops **orig_ops;
+	bool found = false;
+	unsigned int i;
 
-	mutex_lock(&nf_hook_mutex);
-	for (; (p = nf_entry_dereference(*pp)) != NULL; pp = &p->next) {
-		if (nf_hook_entry_ops(p) == reg) {
-			rcu_assign_pointer(*pp, p->next);
-			break;
-		}
-	}
-	mutex_unlock(&nf_hook_mutex);
-	if (!p) {
-		WARN(1, "nf_unregister_net_hook: hook not found!\n");
-		return NULL;
+	orig_ops = nf_hook_entries_get_hook_ops(old);
+	for (i = 0; i < old->num_hook_entries; i++) {
+		if (orig_ops[i] != unreg)
+			continue;
+		WRITE_ONCE(old->hooks[i].hook, accept_all);
+		WRITE_ONCE(orig_ops[i], &dummy_ops);
+		found = true;
+		break;
 	}
+
+	if (found) {
 #ifdef CONFIG_NETFILTER_INGRESS
-	if (reg->pf == NFPROTO_NETDEV && reg->hooknum == NF_NETDEV_INGRESS)
-		net_dec_ingress_queue();
+		if (unreg->pf == NFPROTO_NETDEV && unreg->hooknum == NF_NETDEV_INGRESS)
+			net_dec_ingress_queue();
 #endif
 #ifdef HAVE_JUMP_LABEL
-	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
+		static_key_slow_dec(&nf_hooks_needed[unreg->pf][unreg->hooknum]);
 #endif
-
-	return p;
+	} else {
+		WARN_ONCE(1, "hook not found, pf %d num %d", unreg->pf, unreg->hooknum);
+	}
 }
 
 void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 {
-	struct nf_hook_entry *p = __nf_unregister_net_hook(net, reg);
+	struct nf_hook_entries __rcu **pp;
+	struct nf_hook_entries *p;
 	unsigned int nfq;
 
+	pp = nf_hook_entry_head(net, reg);
+	if (!pp)
+		return;
+
+	mutex_lock(&nf_hook_mutex);
+
+	p = nf_entry_dereference(*pp);
+	if (WARN_ON_ONCE(!p)) {
+		mutex_unlock(&nf_hook_mutex);
+		return;
+	}
+
+	__nf_unregister_net_hook(p, reg);
+
+	p = __nf_hook_entries_try_shrink(pp);
+	mutex_unlock(&nf_hook_mutex);
 	if (!p)
 		return;
 
@@ -173,7 +345,7 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 	nfq = nf_queue_nf_hook_drop(net);
 	if (nfq)
 		synchronize_net();
-	kfree(p);
+	kvfree(p);
 }
 EXPORT_SYMBOL(nf_unregister_net_hook);
 
@@ -200,46 +372,25 @@ EXPORT_SYMBOL(nf_register_net_hooks);
 void nf_unregister_net_hooks(struct net *net, const struct nf_hook_ops *reg,
 			     unsigned int hookcount)
 {
-	struct nf_hook_entry *to_free[16];
-	unsigned int i, n, nfq;
-
-	do {
-		n = min_t(unsigned int, hookcount, ARRAY_SIZE(to_free));
-
-		for (i = 0; i < n; i++)
-			to_free[i] = __nf_unregister_net_hook(net, &reg[i]);
-
-		synchronize_net();
-
-		/* need 2nd synchronize_net() if nfqueue is used, skb
-		 * can get reinjected right before nf_queue_hook_drop()
-		 */
-		nfq = nf_queue_nf_hook_drop(net);
-		if (nfq)
-			synchronize_net();
-
-		for (i = 0; i < n; i++)
-			kfree(to_free[i]);
+	unsigned int i;
 
-		reg += n;
-		hookcount -= n;
-	} while (hookcount > 0);
+	for (i = 0; i < hookcount; i++)
+		nf_unregister_net_hook(net, &reg[i]);
 }
 EXPORT_SYMBOL(nf_unregister_net_hooks);
 
 /* Returns 1 if okfn() needs to be executed by the caller,
  * -EPERM for NF_DROP, 0 otherwise.  Caller must hold rcu_read_lock. */
 int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state,
-		 struct nf_hook_entry *entry)
+		 const struct nf_hook_entries *e, unsigned int s)
 {
 	unsigned int verdict;
 	int ret;
 
-	do {
-		verdict = nf_hook_entry_hookfn(entry, skb, state);
+	for (; s < e->num_hook_entries; s++) {
+		verdict = nf_hook_entry_hookfn(&e->hooks[s], skb, state);
 		switch (verdict & NF_VERDICT_MASK) {
 		case NF_ACCEPT:
-			entry = rcu_dereference(entry->next);
 			break;
 		case NF_DROP:
 			kfree_skb(skb);
@@ -248,8 +399,8 @@ int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state,
 				ret = -EPERM;
 			return ret;
 		case NF_QUEUE:
-			ret = nf_queue(skb, state, &entry, verdict);
-			if (ret == 1 && entry)
+			ret = nf_queue(skb, state, e, s, verdict);
+			if (ret == 1)
 				continue;
 			return ret;
 		default:
@@ -258,7 +409,7 @@ int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state,
 			 */
 			return 0;
 		}
-	} while (entry);
+	}
 
 	return 1;
 }
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index 19f00a47a710..bacd6363946e 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -13,7 +13,8 @@
 
 /* nf_queue.c */
 int nf_queue(struct sk_buff *skb, struct nf_hook_state *state,
-	     struct nf_hook_entry **entryp, unsigned int verdict);
+	     const struct nf_hook_entries *entries, unsigned int index,
+	     unsigned int verdict);
 unsigned int nf_queue_nf_hook_drop(struct net *net);
 
 /* nf_log.c */
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 4f4d80a58fb5..f7e21953b1de 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -112,7 +112,8 @@ unsigned int nf_queue_nf_hook_drop(struct net *net)
 EXPORT_SYMBOL_GPL(nf_queue_nf_hook_drop);
 
 static int __nf_queue(struct sk_buff *skb, const struct nf_hook_state *state,
-		      struct nf_hook_entry *hook_entry, unsigned int queuenum)
+		      const struct nf_hook_entries *entries,
+		      unsigned int index, unsigned int queuenum)
 {
 	int status = -ENOENT;
 	struct nf_queue_entry *entry = NULL;
@@ -140,7 +141,7 @@ static int __nf_queue(struct sk_buff *skb, const struct nf_hook_state *state,
 	*entry = (struct nf_queue_entry) {
 		.skb	= skb,
 		.state	= *state,
-		.hook	= hook_entry,
+		.hook_index = index,
 		.size	= sizeof(*entry) + afinfo->route_key_size,
 	};
 
@@ -163,18 +164,16 @@ static int __nf_queue(struct sk_buff *skb, const struct nf_hook_state *state,
 
 /* Packets leaving via this function must come back through nf_reinject(). */
 int nf_queue(struct sk_buff *skb, struct nf_hook_state *state,
-	     struct nf_hook_entry **entryp, unsigned int verdict)
+	     const struct nf_hook_entries *entries, unsigned int index,
+	     unsigned int verdict)
 {
-	struct nf_hook_entry *entry = *entryp;
 	int ret;
 
-	ret = __nf_queue(skb, state, entry, verdict >> NF_VERDICT_QBITS);
+	ret = __nf_queue(skb, state, entries, index, verdict >> NF_VERDICT_QBITS);
 	if (ret < 0) {
 		if (ret == -ESRCH &&
-		    (verdict & NF_VERDICT_FLAG_QUEUE_BYPASS)) {
-			*entryp = rcu_dereference(entry->next);
+		    (verdict & NF_VERDICT_FLAG_QUEUE_BYPASS))
 			return 1;
-		}
 		kfree_skb(skb);
 	}
 
@@ -183,33 +182,56 @@ int nf_queue(struct sk_buff *skb, struct nf_hook_state *state,
 
 static unsigned int nf_iterate(struct sk_buff *skb,
 			       struct nf_hook_state *state,
-			       struct nf_hook_entry **entryp)
+			       const struct nf_hook_entries *hooks,
+			       unsigned int *index)
 {
-	unsigned int verdict;
+	const struct nf_hook_entry *hook;
+	unsigned int verdict, i = *index;
 
-	do {
+	while (i < hooks->num_hook_entries) {
+		hook = &hooks->hooks[i];
 repeat:
-		verdict = nf_hook_entry_hookfn((*entryp), skb, state);
+		verdict = nf_hook_entry_hookfn(hook, skb, state);
 		if (verdict != NF_ACCEPT) {
 			if (verdict != NF_REPEAT)
 				return verdict;
 			goto repeat;
 		}
-		*entryp = rcu_dereference((*entryp)->next);
-	} while (*entryp);
+		i++;
+	}
 
+	*index = i;
 	return NF_ACCEPT;
 }
 
+/* Caller must hold rcu read-side lock */
 void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 {
-	struct nf_hook_entry *hook_entry = entry->hook;
+	const struct nf_hook_entry *hook_entry;
+	const struct nf_hook_entries *hooks;
 	struct sk_buff *skb = entry->skb;
 	const struct nf_afinfo *afinfo;
+	const struct net *net;
+	unsigned int i;
 	int err;
+	u8 pf;
+
+	net = entry->state.net;
+	pf = entry->state.pf;
+
+	hooks = rcu_dereference(net->nf.hooks[pf][entry->state.hook]);
 
 	nf_queue_entry_release_refs(entry);
 
+	i = entry->hook_index;
+	if (WARN_ON_ONCE(i >= hooks->num_hook_entries)) {
+		kfree_skb(skb);
+		kfree(entry);
+		return;
+	}
+
+	hook_entry = &hooks->hooks[i];
+
 	/* Continue traversal iff userspace said ok... */
 	if (verdict == NF_REPEAT)
 		verdict = nf_hook_entry_hookfn(hook_entry, skb, &entry->state);
@@ -221,27 +243,22 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 	}
 
 	if (verdict == NF_ACCEPT) {
-		hook_entry = rcu_dereference(hook_entry->next);
-		if (hook_entry)
 next_hook:
-			verdict = nf_iterate(skb, &entry->state, &hook_entry);
+		++i;
+		verdict = nf_iterate(skb, &entry->state, hooks, &i);
 	}
 
 	switch (verdict & NF_VERDICT_MASK) {
 	case NF_ACCEPT:
 	case NF_STOP:
-okfn:
 		local_bh_disable();
 		entry->state.okfn(entry->state.net, entry->state.sk, skb);
 		local_bh_enable();
 		break;
 	case NF_QUEUE:
-		err = nf_queue(skb, &entry->state, &hook_entry, verdict);
-		if (err == 1) {
-			if (hook_entry)
-				goto next_hook;
-			goto okfn;
-		}
+		err = nf_queue(skb, &entry->state, hooks, i, verdict);
+		if (err == 1)
+			goto next_hook;
 		break;
 	case NF_STOLEN:
 		break;
-- 
2.1.4


