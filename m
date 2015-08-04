From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/18] netfilter: Per network namespace netfilter hooks.
Date: Tue,  4 Aug 2015 12:02:34 +0200
Message-ID: <1438682568-8346-5-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55975 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933005AbbHDJ5R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 05:57:17 -0400
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

- Add a new set of functions for registering and unregistering per
  network namespace hooks.

- Modify the old global namespace hook functions to use the per
  network namespace hooks in their implementation, so their remains a
  single list that needs to be walked for any hook (this is important
  for keeping the hook priority working and for keeping the code
  walking the hooks simple).

- Only allow registering the per netdevice hooks in the network
  namespace where the network device lives.

- Dynamically allocate the structures in the per network namespace
  hook list in nf_register_net_hook, and unregister them in
  nf_unregister_net_hook.

  Dynamic allocate is required somewhere as the number of network
  namespaces are not fixed so we might as well allocate them in the
  registration function.

  The chain of registered hooks on any list is expected to be small so
  the cost of walking that list to find the entry we are unregistering
  should also be small.

  Performing the management of the dynamically allocated list entries
  in the registration and unregistration functions keeps the complexity
  from spreading.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter.h     |   14 +++-
 include/net/netns/netfilter.h |    1 +
 net/netfilter/core.c          |  182 ++++++++++++++++++++++++++++++++++++-----
 3 files changed, 173 insertions(+), 24 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 60e89348..9bbd110 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -11,6 +11,8 @@
 #include <linux/list.h>
 #include <linux/static_key.h>
 #include <linux/netfilter_defs.h>
+#include <linux/netdevice.h>
+#include <net/net_namespace.h>
 
 #ifdef CONFIG_NETFILTER
 static inline int NF_DROP_GETERR(int verdict)
@@ -118,6 +120,13 @@ struct nf_sockopt_ops {
 };
 
 /* Function to register/unregister hook points. */
+int nf_register_net_hook(struct net *net, const struct nf_hook_ops *ops);
+void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *ops);
+int nf_register_net_hooks(struct net *net, const struct nf_hook_ops *reg,
+			  unsigned int n);
+void nf_unregister_net_hooks(struct net *net, const struct nf_hook_ops *reg,
+			     unsigned int n);
+
 int nf_register_hook(struct nf_hook_ops *reg);
 void nf_unregister_hook(struct nf_hook_ops *reg);
 int nf_register_hooks(struct nf_hook_ops *reg, unsigned int n);
@@ -128,8 +137,6 @@ void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n);
 int nf_register_sockopt(struct nf_sockopt_ops *reg);
 void nf_unregister_sockopt(struct nf_sockopt_ops *reg);
 
-extern struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
-
 #ifdef HAVE_JUMP_LABEL
 extern struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 
@@ -167,7 +174,8 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 				 int (*okfn)(struct sock *, struct sk_buff *),
 				 int thresh)
 {
-	struct list_head *nf_hook_list = &nf_hooks[pf][hook];
+	struct net *net = dev_net(indev ? indev : outdev);
+	struct list_head *nf_hook_list = &net->nf.hooks[pf][hook];
 
 	if (nf_hook_list_active(nf_hook_list, pf, hook)) {
 		struct nf_hook_state state;
diff --git a/include/net/netns/netfilter.h b/include/net/netns/netfilter.h
index 532e4ba..38aa498 100644
--- a/include/net/netns/netfilter.h
+++ b/include/net/netns/netfilter.h
@@ -14,5 +14,6 @@ struct netns_nf {
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header *nf_log_dir_header;
 #endif
+	struct list_head hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 };
 #endif
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index fa4d3c1..56ead1a 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -52,9 +52,6 @@ void nf_unregister_afinfo(const struct nf_afinfo *afinfo)
 }
 EXPORT_SYMBOL_GPL(nf_unregister_afinfo);
 
-struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS] __read_mostly;
-EXPORT_SYMBOL(nf_hooks);
-
 #ifdef HAVE_JUMP_LABEL
 struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 EXPORT_SYMBOL(nf_hooks_needed);
@@ -62,27 +59,40 @@ EXPORT_SYMBOL(nf_hooks_needed);
 
 static DEFINE_MUTEX(nf_hook_mutex);
 
-static struct list_head *find_nf_hook_list(const struct nf_hook_ops *reg)
+static struct list_head *find_nf_hook_list(struct net *net,
+					   const struct nf_hook_ops *reg)
 {
 	struct list_head *nf_hook_list = NULL;
 
 	if (reg->pf != NFPROTO_NETDEV)
-		nf_hook_list = &nf_hooks[reg->pf][reg->hooknum];
+		nf_hook_list = &net->nf.hooks[reg->pf][reg->hooknum];
 	else if (reg->hooknum == NF_NETDEV_INGRESS) {
 #ifdef CONFIG_NETFILTER_INGRESS
-		if (reg->dev)
+		if (reg->dev && dev_net(reg->dev) == net)
 			nf_hook_list = &reg->dev->nf_hooks_ingress;
 #endif
 	}
 	return nf_hook_list;
 }
 
-int nf_register_hook(struct nf_hook_ops *reg)
+int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
 {
 	struct list_head *nf_hook_list;
-	struct nf_hook_ops *elem;
+	struct nf_hook_ops *elem, *new;
+
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
 
-	nf_hook_list = find_nf_hook_list(reg);
+	new->hook     = reg->hook;
+	new->dev      = reg->dev;
+	new->owner    = reg->owner;
+	new->priv     = reg->priv;
+	new->pf       = reg->pf;
+	new->hooknum  = reg->hooknum;
+	new->priority = reg->priority;
+
+	nf_hook_list = find_nf_hook_list(net, reg);
 	if (!nf_hook_list)
 		return -ENOENT;
 
@@ -91,7 +101,7 @@ int nf_register_hook(struct nf_hook_ops *reg)
 		if (reg->priority < elem->priority)
 			break;
 	}
-	list_add_rcu(&reg->list, elem->list.prev);
+	list_add_rcu(&new->list, elem->list.prev);
 	mutex_unlock(&nf_hook_mutex);
 #ifdef CONFIG_NETFILTER_INGRESS
 	if (reg->pf == NFPROTO_NETDEV && reg->hooknum == NF_NETDEV_INGRESS)
@@ -102,13 +112,35 @@ int nf_register_hook(struct nf_hook_ops *reg)
 #endif
 	return 0;
 }
-EXPORT_SYMBOL(nf_register_hook);
+EXPORT_SYMBOL(nf_register_net_hook);
 
-void nf_unregister_hook(struct nf_hook_ops *reg)
+void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 {
+	struct list_head *nf_hook_list;
+	struct nf_hook_ops *elem;
+
+	nf_hook_list = find_nf_hook_list(net, reg);
+	if (!nf_hook_list)
+		return;
+
 	mutex_lock(&nf_hook_mutex);
-	list_del_rcu(&reg->list);
+	list_for_each_entry(elem, nf_hook_list, list) {
+		if ((reg->hook     == elem->hook) &&
+		    (reg->dev      == elem->dev) &&
+		    (reg->owner    == elem->owner) &&
+		    (reg->priv     == elem->priv) &&
+		    (reg->pf       == elem->pf) &&
+		    (reg->hooknum  == elem->hooknum) &&
+		    (reg->priority == elem->priority)) {
+			list_del_rcu(&elem->list);
+			break;
+		}
+	}
 	mutex_unlock(&nf_hook_mutex);
+	if (&elem->list == nf_hook_list) {
+		WARN(1, "nf_unregister_net_hook: hook not found!\n");
+		return;
+	}
 #ifdef CONFIG_NETFILTER_INGRESS
 	if (reg->pf == NFPROTO_NETDEV && reg->hooknum == NF_NETDEV_INGRESS)
 		net_dec_ingress_queue();
@@ -117,7 +149,77 @@ void nf_unregister_hook(struct nf_hook_ops *reg)
 	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
 	synchronize_net();
-	nf_queue_nf_hook_drop(reg);
+	nf_queue_nf_hook_drop(elem);
+	kfree(elem);
+}
+EXPORT_SYMBOL(nf_unregister_net_hook);
+
+int nf_register_net_hooks(struct net *net, const struct nf_hook_ops *reg,
+			  unsigned int n)
+{
+	unsigned int i;
+	int err = 0;
+
+	for (i = 0; i < n; i++) {
+		err = nf_register_net_hook(net, &reg[i]);
+		if (err)
+			goto err;
+	}
+	return err;
+
+err:
+	if (i > 0)
+		nf_unregister_net_hooks(net, reg, i);
+	return err;
+}
+EXPORT_SYMBOL(nf_register_net_hooks);
+
+void nf_unregister_net_hooks(struct net *net, const struct nf_hook_ops *reg,
+			     unsigned int n)
+{
+	while (n-- > 0)
+		nf_unregister_net_hook(net, &reg[n]);
+}
+EXPORT_SYMBOL(nf_unregister_net_hooks);
+
+static LIST_HEAD(nf_hook_list);
+
+int nf_register_hook(struct nf_hook_ops *reg)
+{
+	struct net *net, *last;
+	int ret;
+
+	rtnl_lock();
+	for_each_net(net) {
+		ret = nf_register_net_hook(net, reg);
+		if (ret && ret != -ENOENT)
+			goto rollback;
+	}
+	list_add_tail(&reg->list, &nf_hook_list);
+	rtnl_unlock();
+
+	return 0;
+rollback:
+	last = net;
+	for_each_net(net) {
+		if (net == last)
+			break;
+		nf_unregister_net_hook(net, reg);
+	}
+	rtnl_unlock();
+	return ret;
+}
+EXPORT_SYMBOL(nf_register_hook);
+
+void nf_unregister_hook(struct nf_hook_ops *reg)
+{
+	struct net *net;
+
+	rtnl_lock();
+	list_del(&reg->list);
+	for_each_net(net)
+		nf_unregister_net_hook(net, reg);
+	rtnl_unlock();
 }
 EXPORT_SYMBOL(nf_unregister_hook);
 
@@ -294,8 +396,46 @@ void (*nf_nat_decode_session_hook)(struct sk_buff *, struct flowi *);
 EXPORT_SYMBOL(nf_nat_decode_session_hook);
 #endif
 
+static int nf_register_hook_list(struct net *net)
+{
+	struct nf_hook_ops *elem;
+	int ret;
+
+	rtnl_lock();
+	list_for_each_entry(elem, &nf_hook_list, list) {
+		ret = nf_register_net_hook(net, elem);
+		if (ret && ret != -ENOENT)
+			goto out_undo;
+	}
+	rtnl_unlock();
+	return 0;
+
+out_undo:
+	list_for_each_entry_continue_reverse(elem, &nf_hook_list, list)
+		nf_unregister_net_hook(net, elem);
+	rtnl_unlock();
+	return ret;
+}
+
+static void nf_unregister_hook_list(struct net *net)
+{
+	struct nf_hook_ops *elem;
+
+	rtnl_lock();
+	list_for_each_entry(elem, &nf_hook_list, list)
+		nf_unregister_net_hook(net, elem);
+	rtnl_unlock();
+}
+
 static int __net_init netfilter_net_init(struct net *net)
 {
+	int i, h, ret;
+
+	for (i = 0; i < ARRAY_SIZE(net->nf.hooks); i++) {
+		for (h = 0; h < NF_MAX_HOOKS; h++)
+			INIT_LIST_HEAD(&net->nf.hooks[i][h]);
+	}
+
 #ifdef CONFIG_PROC_FS
 	net->nf.proc_netfilter = proc_net_mkdir(net, "netfilter",
 						net->proc_net);
@@ -306,11 +446,16 @@ static int __net_init netfilter_net_init(struct net *net)
 		return -ENOMEM;
 	}
 #endif
-	return 0;
+	ret = nf_register_hook_list(net);
+	if (ret)
+		remove_proc_entry("netfilter", net->proc_net);
+
+	return ret;
 }
 
 static void __net_exit netfilter_net_exit(struct net *net)
 {
+	nf_unregister_hook_list(net);
 	remove_proc_entry("netfilter", net->proc_net);
 }
 
@@ -321,12 +466,7 @@ static struct pernet_operations netfilter_net_ops = {
 
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
-- 
1.7.10.4
