From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/18] netfilter: fix possible removal of wrong hook
Date: Tue,  4 Aug 2015 12:02:43 +0200
Message-ID: <1438682568-8346-14-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56068 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933099AbbHDJ5g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 05:57:36 -0400
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nf_unregister_net_hook() uses the nf_hook_ops fields as tuple to look up for
the corresponding hook in the list. However, we may have two hooks with exactly
the same configuration.

This shouldn't be a problem for nftables since every new chain has an unique
priv field set, but this may still cause us problems in the future, so better
address this problem now by keeping a reference to the original nf_hook_ops
structure to make sure we delete the right hook from nf_unregister_net_hook().

Fixes: 085db2c04557 ("netfilter: Per network namespace netfilter hooks.")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/core.c |   41 +++++++++++++++++++----------------------
 1 file changed, 19 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 12504fbb..0ecb2b5 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -78,26 +78,27 @@ static struct list_head *find_nf_hook_list(struct net *net,
 	return nf_hook_list;
 }
 
+struct nf_hook_entry {
+	const struct nf_hook_ops	*orig_ops;
+	struct nf_hook_ops		ops;
+};
+
 int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
 {
 	struct list_head *nf_hook_list;
-	struct nf_hook_ops *elem, *new;
+	struct nf_hook_entry *entry;
+	struct nf_hook_ops *elem;
 
-	new = kzalloc(sizeof(*new), GFP_KERNEL);
-	if (!new)
+	entry = kmalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry)
 		return -ENOMEM;
 
-	new->hook     = reg->hook;
-	new->dev      = reg->dev;
-	new->owner    = reg->owner;
-	new->priv     = reg->priv;
-	new->pf       = reg->pf;
-	new->hooknum  = reg->hooknum;
-	new->priority = reg->priority;
+	entry->orig_ops	= reg;
+	entry->ops	= *reg;
 
 	nf_hook_list = find_nf_hook_list(net, reg);
 	if (!nf_hook_list) {
-		kfree(new);
+		kfree(entry);
 		return -ENOENT;
 	}
 
@@ -106,7 +107,7 @@ int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
 		if (reg->priority < elem->priority)
 			break;
 	}
-	list_add_rcu(&new->list, elem->list.prev);
+	list_add_rcu(&entry->ops.list, elem->list.prev);
 	mutex_unlock(&nf_hook_mutex);
 #ifdef CONFIG_NETFILTER_INGRESS
 	if (reg->pf == NFPROTO_NETDEV && reg->hooknum == NF_NETDEV_INGRESS)
@@ -122,6 +123,7 @@ EXPORT_SYMBOL(nf_register_net_hook);
 void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 {
 	struct list_head *nf_hook_list;
+	struct nf_hook_entry *entry;
 	struct nf_hook_ops *elem;
 
 	nf_hook_list = find_nf_hook_list(net, reg);
@@ -130,14 +132,9 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 
 	mutex_lock(&nf_hook_mutex);
 	list_for_each_entry(elem, nf_hook_list, list) {
-		if ((reg->hook     == elem->hook) &&
-		    (reg->dev      == elem->dev) &&
-		    (reg->owner    == elem->owner) &&
-		    (reg->priv     == elem->priv) &&
-		    (reg->pf       == elem->pf) &&
-		    (reg->hooknum  == elem->hooknum) &&
-		    (reg->priority == elem->priority)) {
-			list_del_rcu(&elem->list);
+		entry = container_of(elem, struct nf_hook_entry, ops);
+		if (entry->orig_ops == reg) {
+			list_del_rcu(&entry->ops.list);
 			break;
 		}
 	}
@@ -154,8 +151,8 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
 	synchronize_net();
-	nf_queue_nf_hook_drop(net, elem);
-	kfree(elem);
+	nf_queue_nf_hook_drop(net, &entry->ops);
+	kfree(entry);
 }
 EXPORT_SYMBOL(nf_unregister_net_hook);
 
-- 
1.7.10.4
