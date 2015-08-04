From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/18] netfilter: rename local nf_hook_list to hook_list
Date: Tue,  4 Aug 2015 12:02:44 +0200
Message-ID: <1438682568-8346-15-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56076 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933142AbbHDJ5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 05:57:38 -0400
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

085db2c04557 ("netfilter: Per network namespace netfilter hooks.") introduced a
new nf_hook_list that is global, so let's avoid this overlap.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter.h |   14 +++++++-------
 net/netfilter/core.c      |   28 ++++++++++++++--------------
 2 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index e01da73..d788ce6 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -140,20 +140,20 @@ void nf_unregister_sockopt(struct nf_sockopt_ops *reg);
 #ifdef HAVE_JUMP_LABEL
 extern struct static_key nf_hooks_needed[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 
-static inline bool nf_hook_list_active(struct list_head *nf_hook_list,
+static inline bool nf_hook_list_active(struct list_head *hook_list,
 				       u_int8_t pf, unsigned int hook)
 {
 	if (__builtin_constant_p(pf) &&
 	    __builtin_constant_p(hook))
 		return static_key_false(&nf_hooks_needed[pf][hook]);
 
-	return !list_empty(nf_hook_list);
+	return !list_empty(hook_list);
 }
 #else
-static inline bool nf_hook_list_active(struct list_head *nf_hook_list,
+static inline bool nf_hook_list_active(struct list_head *hook_list,
 				       u_int8_t pf, unsigned int hook)
 {
-	return !list_empty(nf_hook_list);
+	return !list_empty(hook_list);
 }
 #endif
 
@@ -175,12 +175,12 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 				 int thresh)
 {
 	struct net *net = dev_net(indev ? indev : outdev);
-	struct list_head *nf_hook_list = &net->nf.hooks[pf][hook];
+	struct list_head *hook_list = &net->nf.hooks[pf][hook];
 
-	if (nf_hook_list_active(nf_hook_list, pf, hook)) {
+	if (nf_hook_list_active(hook_list, pf, hook)) {
 		struct nf_hook_state state;
 
-		nf_hook_state_init(&state, nf_hook_list, hook, thresh,
+		nf_hook_state_init(&state, hook_list, hook, thresh,
 				   pf, indev, outdev, sk, okfn);
 		return nf_hook_slow(skb, &state);
 	}
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 0ecb2b5..2a5a070 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -62,20 +62,20 @@ EXPORT_SYMBOL(nf_hooks_needed);
 
 static DEFINE_MUTEX(nf_hook_mutex);
 
-static struct list_head *find_nf_hook_list(struct net *net,
+static struct list_head *nf_find_hook_list(struct net *net,
 					   const struct nf_hook_ops *reg)
 {
-	struct list_head *nf_hook_list = NULL;
+	struct list_head *hook_list = NULL;
 
 	if (reg->pf != NFPROTO_NETDEV)
-		nf_hook_list = &net->nf.hooks[reg->pf][reg->hooknum];
+		hook_list = &net->nf.hooks[reg->pf][reg->hooknum];
 	else if (reg->hooknum == NF_NETDEV_INGRESS) {
 #ifdef CONFIG_NETFILTER_INGRESS
 		if (reg->dev && dev_net(reg->dev) == net)
-			nf_hook_list = &reg->dev->nf_hooks_ingress;
+			hook_list = &reg->dev->nf_hooks_ingress;
 #endif
 	}
-	return nf_hook_list;
+	return hook_list;
 }
 
 struct nf_hook_entry {
@@ -85,7 +85,7 @@ struct nf_hook_entry {
 
 int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
 {
-	struct list_head *nf_hook_list;
+	struct list_head *hook_list;
 	struct nf_hook_entry *entry;
 	struct nf_hook_ops *elem;
 
@@ -96,14 +96,14 @@ int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
 	entry->orig_ops	= reg;
 	entry->ops	= *reg;
 
-	nf_hook_list = find_nf_hook_list(net, reg);
-	if (!nf_hook_list) {
+	hook_list = nf_find_hook_list(net, reg);
+	if (!hook_list) {
 		kfree(entry);
 		return -ENOENT;
 	}
 
 	mutex_lock(&nf_hook_mutex);
-	list_for_each_entry(elem, nf_hook_list, list) {
+	list_for_each_entry(elem, hook_list, list) {
 		if (reg->priority < elem->priority)
 			break;
 	}
@@ -122,16 +122,16 @@ EXPORT_SYMBOL(nf_register_net_hook);
 
 void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 {
-	struct list_head *nf_hook_list;
+	struct list_head *hook_list;
 	struct nf_hook_entry *entry;
 	struct nf_hook_ops *elem;
 
-	nf_hook_list = find_nf_hook_list(net, reg);
-	if (!nf_hook_list)
+	hook_list = nf_find_hook_list(net, reg);
+	if (!hook_list)
 		return;
 
 	mutex_lock(&nf_hook_mutex);
-	list_for_each_entry(elem, nf_hook_list, list) {
+	list_for_each_entry(elem, hook_list, list) {
 		entry = container_of(elem, struct nf_hook_entry, ops);
 		if (entry->orig_ops == reg) {
 			list_del_rcu(&entry->ops.list);
@@ -139,7 +139,7 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 		}
 	}
 	mutex_unlock(&nf_hook_mutex);
-	if (&elem->list == nf_hook_list) {
+	if (&elem->list == hook_list) {
 		WARN(1, "nf_unregister_net_hook: hook not found!\n");
 		return;
 	}
-- 
1.7.10.4
