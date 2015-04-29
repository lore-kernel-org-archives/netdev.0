From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/6] netfilter: move generic hook infrastructure into net/core/hooks.c
Date: Wed, 29 Apr 2015 20:53:07 +0200
Message-ID: <1430333589-4940-5-git-send-email-pablo@netfilter.org>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, jhs@mojatatu.com
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch moves the very basic hook infrastructure into net/core/hooks.c
and it also adds a new CONFIG_NETFILTER_HOOKS kconfig switch.

The idea is to allow CONFIG_NETFILTER_HOOKS selection from qdisc ingress
without depending on the full Netfilter layer 3 hooks (ie. CONFIG_NETFILTER).

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 MAINTAINERS                      |    1 +
 include/linux/netfilter.h        |   96 +----------------------
 include/linux/netfilter_hooks.h  |  117 ++++++++++++++++++++++++++++
 include/net/netfilter/nf_queue.h |    1 +
 net/Kconfig                      |    7 ++
 net/core/Makefile                |    1 +
 net/core/dev.c                   |    2 +
 net/core/hooks.c                 |  159 ++++++++++++++++++++++++++++++++++++++
 net/netfilter/core.c             |  149 +----------------------------------
 net/netfilter/nf_internals.h     |    2 -
 10 files changed, 290 insertions(+), 245 deletions(-)
 create mode 100644 include/linux/netfilter_hooks.h
 create mode 100644 net/core/hooks.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 2e5bbc0..a948650 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6739,6 +6739,7 @@ F:	include/uapi/linux/netfilter/
 F:	net/*/netfilter.c
 F:	net/*/netfilter/
 F:	net/netfilter/
+F:	net/core/hooks.c
 
 NETLABEL
 M:	Paul Moore <paul@paul-moore.com>
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 49d0063..ae1a239 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -12,11 +12,6 @@
 #include <linux/static_key.h>
 #include <uapi/linux/netfilter.h>
 #ifdef CONFIG_NETFILTER
-static inline int NF_DROP_GETERR(int verdict)
-{
-	return -(verdict >> NF_VERDICT_QBITS);
-}
-
 static inline int nf_inet_addr_cmp(const union nf_inet_addr *a1,
 				   const union nf_inet_addr *a2)
 {
@@ -38,62 +33,6 @@ static inline void nf_inet_addr_mask(const union nf_inet_addr *a1,
 
 int netfilter_init(void);
 
-/* Largest hook number + 1 */
-#define NF_MAX_HOOKS 8
-
-struct sk_buff;
-
-struct nf_hook_ops;
-
-struct sock;
-
-struct nf_hook_state {
-	unsigned int hook;
-	int thresh;
-	u_int8_t pf;
-	struct net_device *in;
-	struct net_device *out;
-	struct sock *sk;
-	struct list_head *hook_list;
-	int (*okfn)(struct sock *, struct sk_buff *);
-};
-
-static inline void nf_hook_state_init(struct nf_hook_state *p,
-				      struct list_head *hook_list,
-				      unsigned int hook,
-				      int thresh, u_int8_t pf,
-				      struct net_device *indev,
-				      struct net_device *outdev,
-				      struct sock *sk,
-				      int (*okfn)(struct sock *, struct sk_buff *))
-{
-	p->hook = hook;
-	p->thresh = thresh;
-	p->pf = pf;
-	p->in = indev;
-	p->out = outdev;
-	p->sk = sk;
-	p->hook_list = hook_list;
-	p->okfn = okfn;
-}
-
-typedef unsigned int nf_hookfn(const struct nf_hook_ops *ops,
-			       struct sk_buff *skb,
-			       const struct nf_hook_state *state);
-
-struct nf_hook_ops {
-	struct list_head 	list;
-
-	/* User fills in from here down. */
-	nf_hookfn		*hook;
-	struct module		*owner;
-	void			*priv;
-	u_int8_t		pf;
-	unsigned int		hooknum;
-	/* Hooks are ordered in ascending priority. */
-	int			priority;
-};
-
 struct nf_sockopt_ops {
 	struct list_head list;
 
@@ -118,45 +57,12 @@ struct nf_sockopt_ops {
 	struct module *owner;
 };
 
-/* Function to register/unregister hook points. */
-int nf_register_hook(struct nf_hook_ops *reg);
-void nf_unregister_hook(struct nf_hook_ops *reg);
-int nf_register_hooks(struct nf_hook_ops *reg, unsigned int n);
-void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n);
-
 /* Functions to register get/setsockopt ranges (non-inclusive).  You
    need to check permissions yourself! */
 int nf_register_sockopt(struct nf_sockopt_ops *reg);
 void nf_unregister_sockopt(struct nf_sockopt_ops *reg);
 
-extern struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
-
-#ifdef HAVE_JUMP_LABEL
-extern struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
-
-static inline bool nf_hook_list_active(struct list_head *nf_hook_list,
-				       u_int8_t pf, unsigned int hook)
-{
-	if (__builtin_constant_p(pf) &&
-	    __builtin_constant_p(hook))
-		return static_key_false(&nf_hooks_needed[pf][hook]);
-
-	return !list_empty(nf_hook_list);
-}
-#else
-static inline bool nf_hook_list_active(struct list_head *nf_hook_list,
-				       u_int8_t pf, unsigned int hook)
-{
-	return !list_empty(nf_hook_list);
-}
-#endif
-
-static inline bool nf_hooks_active(u_int8_t pf, unsigned int hook)
-{
-	return nf_hook_list_active(&nf_hooks[pf][hook], pf, hook);
-}
-
-int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state);
+#include <linux/netfilter_hooks.h>
 
 /**
  *	nf_hook_thresh - call a netfilter hook
diff --git a/include/linux/netfilter_hooks.h b/include/linux/netfilter_hooks.h
new file mode 100644
index 0000000..d7a65e6
--- /dev/null
+++ b/include/linux/netfilter_hooks.h
@@ -0,0 +1,117 @@
+#ifndef _NETFILTER_HOOKS_H_
+#define _NETFILTER_HOOKS_H_
+
+static inline int NF_DROP_GETERR(int verdict)
+{
+	return -(verdict >> NF_VERDICT_QBITS);
+}
+
+/* Largest hook number + 1 */
+#define NF_MAX_HOOKS 8
+
+struct sk_buff;
+
+struct nf_hook_ops;
+
+struct sock;
+
+struct nf_hook_state {
+	unsigned int hook;
+	int thresh;
+	u_int8_t pf;
+	struct net_device *in;
+	struct net_device *out;
+	struct sock *sk;
+	struct list_head *hook_list;
+	int (*okfn)(struct sock *, struct sk_buff *);
+};
+
+static inline void nf_hook_state_init(struct nf_hook_state *p,
+				      struct list_head *hook_list,
+				      unsigned int hook,
+				      int thresh, u_int8_t pf,
+				      struct net_device *indev,
+				      struct net_device *outdev,
+				      struct sock *sk,
+				      int (*okfn)(struct sock *, struct sk_buff *))
+{
+	p->hook = hook;
+	p->thresh = thresh;
+	p->pf = pf;
+	p->in = indev;
+	p->out = outdev;
+	p->sk = sk;
+	p->hook_list = hook_list;
+	p->okfn = okfn;
+}
+
+typedef unsigned int nf_hookfn(const struct nf_hook_ops *ops,
+			       struct sk_buff *skb,
+			       const struct nf_hook_state *state);
+
+struct nf_hook_ops {
+	struct list_head	list;
+
+	/* User fills in from here down. */
+	nf_hookfn		*hook;
+	struct module		*owner;
+	void			*priv;
+	u_int8_t		pf;
+	unsigned int		hooknum;
+	/* Hooks are ordered in ascending priority. */
+	int			priority;
+};
+
+/* Function to register/unregister hook points. */
+int nf_register_hook(struct nf_hook_ops *reg);
+void nf_unregister_hook(struct nf_hook_ops *reg);
+int nf_register_hooks(struct nf_hook_ops *reg, unsigned int n);
+void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n);
+
+extern struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
+
+#ifdef HAVE_JUMP_LABEL
+extern struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
+
+static inline bool nf_hook_list_active(struct list_head *nf_hook_list,
+				       u_int8_t pf, unsigned int hook)
+{
+	if (__builtin_constant_p(pf) &&
+	    __builtin_constant_p(hook))
+		return static_key_false(&nf_hooks_needed[pf][hook]);
+
+	return !list_empty(nf_hook_list);
+}
+#else
+static inline bool nf_hook_list_active(struct list_head *nf_hook_list,
+				       u_int8_t pf, unsigned int hook)
+{
+	return !list_empty(nf_hook_list);
+}
+#endif
+
+static inline bool nf_hooks_active(u_int8_t pf, unsigned int hook)
+{
+	return nf_hook_list_active(&nf_hooks[pf][hook], pf, hook);
+}
+
+int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state);
+
+#ifdef CONFIG_NETFILTER_HOOKS
+void netfilter_hooks_init(void);
+#else
+static inline void netfilter_hooks_init(void) {}
+#endif
+
+#ifndef CONFIG_NETFILTER
+static inline int nf_queue(struct sk_buff *skb, struct nf_hook_ops *elem,
+			   struct nf_hook_state *state, unsigned int queuenum)
+{
+	return -EOPNOTSUPP;
+}
+#else
+int nf_queue(struct sk_buff *skb, struct nf_hook_ops *elem,
+	     struct nf_hook_state *state, unsigned int queuenum);
+#endif /* CONFIG_NETFILTER */
+
+#endif /* _NETFILTER_HOOKS_H_ */
diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
index d81d584..98ad639 100644
--- a/include/net/netfilter/nf_queue.h
+++ b/include/net/netfilter/nf_queue.h
@@ -4,6 +4,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/jhash.h>
+#include <linux/netfilter_hooks.h>
 
 /* Each queued (to userspace) skbuff has one of these. */
 struct nf_queue_entry {
diff --git a/net/Kconfig b/net/Kconfig
index 44dd578..710d393 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -103,7 +103,14 @@ config NETWORK_PHY_TIMESTAMPING
 
 	  If you are unsure how to answer this question, answer N.
 
+config NETFILTER_HOOKS
+	bool "Generic Netfilter hook infrastructure"
+	help
+	  If this option is enabled, the kernel will include support
+	  for the generic Netfilter hook infrastructure.
+
 menuconfig NETFILTER
+	select NETFILTER_HOOKS
 	bool "Network packet filtering framework (Netfilter)"
 	---help---
 	  Netfilter is a framework for filtering and mangling network packets
diff --git a/net/core/Makefile b/net/core/Makefile
index fec0856..810f9a4 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -23,3 +23,4 @@ obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
 obj-$(CONFIG_NET_PTP_CLASSIFY) += ptp_classifier.o
 obj-$(CONFIG_CGROUP_NET_PRIO) += netprio_cgroup.o
 obj-$(CONFIG_CGROUP_NET_CLASSID) += netclassid_cgroup.o
+obj-$(CONFIG_NETFILTER_HOOKS) += hooks.o
diff --git a/net/core/dev.c b/net/core/dev.c
index c7ba038..3d63b85 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -135,6 +135,7 @@
 #include <linux/if_macvlan.h>
 #include <linux/errqueue.h>
 #include <linux/hrtimer.h>
+#include <linux/netfilter_hooks.h>
 
 #include "net-sysfs.h"
 
@@ -7523,6 +7524,7 @@ static int __init net_dev_init(void)
 	hotcpu_notifier(dev_cpu_callback, 0);
 	dst_init();
 	rc = 0;
+	netfilter_hooks_init();
 out:
 	return rc;
 }
diff --git a/net/core/hooks.c b/net/core/hooks.c
new file mode 100644
index 0000000..aa9c56c
--- /dev/null
+++ b/net/core/hooks.c
@@ -0,0 +1,159 @@
+#include <linux/kernel.h>
+#include <linux/netfilter.h>
+#include <linux/init.h>
+#include <linux/skbuff.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/mutex.h>
+#include <linux/netfilter_hooks.h>
+
+struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS] __read_mostly;
+EXPORT_SYMBOL(nf_hooks);
+
+#ifdef HAVE_JUMP_LABEL
+struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
+EXPORT_SYMBOL(nf_hooks_needed);
+#endif
+
+static DEFINE_MUTEX(nf_hook_mutex);
+
+int nf_register_hook(struct nf_hook_ops *reg)
+{
+	struct nf_hook_ops *elem;
+
+	mutex_lock(&nf_hook_mutex);
+	list_for_each_entry(elem, &nf_hooks[reg->pf][reg->hooknum], list) {
+		if (reg->priority < elem->priority)
+			break;
+	}
+	list_add_rcu(&reg->list, elem->list.prev);
+	mutex_unlock(&nf_hook_mutex);
+#ifdef HAVE_JUMP_LABEL
+	static_key_slow_inc(&nf_hooks_needed[reg->pf][reg->hooknum]);
+#endif
+	return 0;
+}
+EXPORT_SYMBOL(nf_register_hook);
+
+void nf_unregister_hook(struct nf_hook_ops *reg)
+{
+	mutex_lock(&nf_hook_mutex);
+	list_del_rcu(&reg->list);
+	mutex_unlock(&nf_hook_mutex);
+#ifdef HAVE_JUMP_LABEL
+	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
+#endif
+	synchronize_net();
+}
+EXPORT_SYMBOL(nf_unregister_hook);
+
+int nf_register_hooks(struct nf_hook_ops *reg, unsigned int n)
+{
+	unsigned int i;
+	int err = 0;
+
+	for (i = 0; i < n; i++) {
+		err = nf_register_hook(&reg[i]);
+		if (err)
+			goto err;
+	}
+	return err;
+
+err:
+	if (i > 0)
+		nf_unregister_hooks(reg, i);
+	return err;
+}
+EXPORT_SYMBOL(nf_register_hooks);
+
+void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n)
+{
+	while (n-- > 0)
+		nf_unregister_hook(&reg[n]);
+}
+EXPORT_SYMBOL(nf_unregister_hooks);
+
+unsigned int nf_iterate(struct list_head *head,
+			struct sk_buff *skb,
+			struct nf_hook_state *state,
+			struct nf_hook_ops **elemp)
+{
+	unsigned int verdict;
+
+	/*
+	 * The caller must not block between calls to this
+	 * function because of risk of continuing from deleted element.
+	 */
+	list_for_each_entry_continue_rcu((*elemp), head, list) {
+		if (state->thresh > (*elemp)->priority)
+			continue;
+
+		/* Optimization: we don't need to hold module
+		   reference here, since function can't sleep. --RR */
+repeat:
+		verdict = (*elemp)->hook(*elemp, skb, state);
+		if (verdict != NF_ACCEPT) {
+#ifdef CONFIG_NETFILTER_DEBUG
+			if (unlikely((verdict & NF_VERDICT_MASK)
+							> NF_MAX_VERDICT)) {
+				NFDEBUG("Evil return from %p(%u).\n",
+					(*elemp)->hook, state->hook);
+				continue;
+			}
+#endif
+			if (verdict != NF_REPEAT)
+				return verdict;
+			goto repeat;
+		}
+	}
+	return NF_ACCEPT;
+}
+
+
+/* Returns 1 if okfn() needs to be executed by the caller,
+ * -EPERM for NF_DROP, 0 otherwise. */
+int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state)
+{
+	struct nf_hook_ops *elem;
+	unsigned int verdict;
+	int ret = 0;
+
+	/* We may already have this, but read-locks nest anyway */
+	rcu_read_lock();
+
+	elem = list_entry_rcu(state->hook_list, struct nf_hook_ops, list);
+next_hook:
+	verdict = nf_iterate(state->hook_list, skb, state, &elem);
+	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
+		ret = 1;
+	} else if ((verdict & NF_VERDICT_MASK) == NF_DROP) {
+		kfree_skb(skb);
+		ret = NF_DROP_GETERR(verdict);
+		if (ret == 0)
+			ret = -EPERM;
+	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
+		int err = nf_queue(skb, elem, state,
+				   verdict >> NF_VERDICT_QBITS);
+		if (err < 0) {
+			if (err == -ECANCELED)
+				goto next_hook;
+			if (err == -ESRCH &&
+			   (verdict & NF_VERDICT_FLAG_QUEUE_BYPASS))
+				goto next_hook;
+			kfree_skb(skb);
+		}
+	}
+	rcu_read_unlock();
+	return ret;
+}
+EXPORT_SYMBOL(nf_hook_slow);
+
+void __init netfilter_hooks_init(void)
+{
+	int i, h;
+
+	for (i = 0; i < ARRAY_SIZE(nf_hooks); i++) {
+		for (h = 0; h < NF_MAX_HOOKS; h++)
+			INIT_LIST_HEAD(&nf_hooks[i][h]);
+	}
+}
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e418cfd..ec20fba2 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -52,148 +52,6 @@ void nf_unregister_afinfo(const struct nf_afinfo *afinfo)
 }
 EXPORT_SYMBOL_GPL(nf_unregister_afinfo);
 
-struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS] __read_mostly;
-EXPORT_SYMBOL(nf_hooks);
-
-#ifdef HAVE_JUMP_LABEL
-struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
-EXPORT_SYMBOL(nf_hooks_needed);
-#endif
-
-static DEFINE_MUTEX(nf_hook_mutex);
-
-int nf_register_hook(struct nf_hook_ops *reg)
-{
-	struct nf_hook_ops *elem;
-
-	mutex_lock(&nf_hook_mutex);
-	list_for_each_entry(elem, &nf_hooks[reg->pf][reg->hooknum], list) {
-		if (reg->priority < elem->priority)
-			break;
-	}
-	list_add_rcu(&reg->list, elem->list.prev);
-	mutex_unlock(&nf_hook_mutex);
-#ifdef HAVE_JUMP_LABEL
-	static_key_slow_inc(&nf_hooks_needed[reg->pf][reg->hooknum]);
-#endif
-	return 0;
-}
-EXPORT_SYMBOL(nf_register_hook);
-
-void nf_unregister_hook(struct nf_hook_ops *reg)
-{
-	mutex_lock(&nf_hook_mutex);
-	list_del_rcu(&reg->list);
-	mutex_unlock(&nf_hook_mutex);
-#ifdef HAVE_JUMP_LABEL
-	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
-#endif
-	synchronize_net();
-}
-EXPORT_SYMBOL(nf_unregister_hook);
-
-int nf_register_hooks(struct nf_hook_ops *reg, unsigned int n)
-{
-	unsigned int i;
-	int err = 0;
-
-	for (i = 0; i < n; i++) {
-		err = nf_register_hook(&reg[i]);
-		if (err)
-			goto err;
-	}
-	return err;
-
-err:
-	if (i > 0)
-		nf_unregister_hooks(reg, i);
-	return err;
-}
-EXPORT_SYMBOL(nf_register_hooks);
-
-void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n)
-{
-	while (n-- > 0)
-		nf_unregister_hook(&reg[n]);
-}
-EXPORT_SYMBOL(nf_unregister_hooks);
-
-unsigned int nf_iterate(struct list_head *head,
-			struct sk_buff *skb,
-			struct nf_hook_state *state,
-			struct nf_hook_ops **elemp)
-{
-	unsigned int verdict;
-
-	/*
-	 * The caller must not block between calls to this
-	 * function because of risk of continuing from deleted element.
-	 */
-	list_for_each_entry_continue_rcu((*elemp), head, list) {
-		if (state->thresh > (*elemp)->priority)
-			continue;
-
-		/* Optimization: we don't need to hold module
-		   reference here, since function can't sleep. --RR */
-repeat:
-		verdict = (*elemp)->hook(*elemp, skb, state);
-		if (verdict != NF_ACCEPT) {
-#ifdef CONFIG_NETFILTER_DEBUG
-			if (unlikely((verdict & NF_VERDICT_MASK)
-							> NF_MAX_VERDICT)) {
-				NFDEBUG("Evil return from %p(%u).\n",
-					(*elemp)->hook, state->hook);
-				continue;
-			}
-#endif
-			if (verdict != NF_REPEAT)
-				return verdict;
-			goto repeat;
-		}
-	}
-	return NF_ACCEPT;
-}
-
-
-/* Returns 1 if okfn() needs to be executed by the caller,
- * -EPERM for NF_DROP, 0 otherwise. */
-int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state)
-{
-	struct nf_hook_ops *elem;
-	unsigned int verdict;
-	int ret = 0;
-
-	/* We may already have this, but read-locks nest anyway */
-	rcu_read_lock();
-
-	elem = list_entry_rcu(state->hook_list, struct nf_hook_ops, list);
-next_hook:
-	verdict = nf_iterate(state->hook_list, skb, state, &elem);
-	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
-		ret = 1;
-	} else if ((verdict & NF_VERDICT_MASK) == NF_DROP) {
-		kfree_skb(skb);
-		ret = NF_DROP_GETERR(verdict);
-		if (ret == 0)
-			ret = -EPERM;
-	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
-		int err = nf_queue(skb, elem, state,
-				   verdict >> NF_VERDICT_QBITS);
-		if (err < 0) {
-			if (err == -ECANCELED)
-				goto next_hook;
-			if (err == -ESRCH &&
-			   (verdict & NF_VERDICT_FLAG_QUEUE_BYPASS))
-				goto next_hook;
-			kfree_skb(skb);
-		}
-	}
-	rcu_read_unlock();
-	return ret;
-}
-EXPORT_SYMBOL(nf_hook_slow);
-
-
 int skb_make_writable(struct sk_buff *skb, unsigned int writable_len)
 {
 	if (writable_len > skb->len)
@@ -292,12 +150,7 @@ static struct pernet_operations netfilter_net_ops = {
 
 int __init netfilter_init(void)
 {
-	int i, h, ret;
-
-	for (i = 0; i < ARRAY_SIZE(nf_hooks); i++) {
-		for (h = 0; h < NF_MAX_HOOKS; h++)
-			INIT_LIST_HEAD(&nf_hooks[i][h]);
-	}
+	int ret;
 
 	ret = register_pernet_subsys(&netfilter_net_ops);
 	if (ret < 0)
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index ea7f367..ae7b90e 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -17,8 +17,6 @@ unsigned int nf_iterate(struct list_head *head, struct sk_buff *skb,
 			struct nf_hook_state *state, struct nf_hook_ops **elemp);
 
 /* nf_queue.c */
-int nf_queue(struct sk_buff *skb, struct nf_hook_ops *elem,
-	     struct nf_hook_state *state, unsigned int queuenum);
 int __init netfilter_queue_init(void);
 
 /* nf_log.c */
-- 
1.7.10.4

