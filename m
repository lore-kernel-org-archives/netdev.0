From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/29] netfilter: nf_tables: introduce nft_chain_parse_hook()
Date: Mon,  5 Sep 2016 12:58:31 +0200
Message-ID: <1473073124-5015-17-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35198 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933531AbcIEK7K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:59:10 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7408A2EFEC8
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:09 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5906A1153FD
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:09 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 001C3114D6C
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:06 +0200 (CEST)
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a new function to wrap the code that parses the chain hook
configuration so we can reuse this code to validate chain updates.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 152 +++++++++++++++++++++++++-----------------
 1 file changed, 89 insertions(+), 63 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 7e1c876..463fcad 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1196,6 +1196,83 @@ static void nf_tables_chain_destroy(struct nft_chain *chain)
 	}
 }
 
+struct nft_chain_hook {
+	u32				num;
+	u32				priority;
+	const struct nf_chain_type	*type;
+	struct net_device		*dev;
+};
+
+static int nft_chain_parse_hook(struct net *net,
+				const struct nlattr * const nla[],
+				struct nft_af_info *afi,
+				struct nft_chain_hook *hook, bool create)
+{
+	struct nlattr *ha[NFTA_HOOK_MAX + 1];
+	const struct nf_chain_type *type;
+	struct net_device *dev;
+	int err;
+
+	err = nla_parse_nested(ha, NFTA_HOOK_MAX, nla[NFTA_CHAIN_HOOK],
+			       nft_hook_policy);
+	if (err < 0)
+		return err;
+
+	if (ha[NFTA_HOOK_HOOKNUM] == NULL ||
+	    ha[NFTA_HOOK_PRIORITY] == NULL)
+		return -EINVAL;
+
+	hook->num = ntohl(nla_get_be32(ha[NFTA_HOOK_HOOKNUM]));
+	if (hook->num >= afi->nhooks)
+		return -EINVAL;
+
+	hook->priority = ntohl(nla_get_be32(ha[NFTA_HOOK_PRIORITY]));
+
+	type = chain_type[afi->family][NFT_CHAIN_T_DEFAULT];
+	if (nla[NFTA_CHAIN_TYPE]) {
+		type = nf_tables_chain_type_lookup(afi, nla[NFTA_CHAIN_TYPE],
+						   create);
+		if (IS_ERR(type))
+			return PTR_ERR(type);
+	}
+	if (!(type->hook_mask & (1 << hook->num)))
+		return -EOPNOTSUPP;
+	if (!try_module_get(type->owner))
+		return -ENOENT;
+
+	hook->type = type;
+
+	hook->dev = NULL;
+	if (afi->flags & NFT_AF_NEEDS_DEV) {
+		char ifname[IFNAMSIZ];
+
+		if (!ha[NFTA_HOOK_DEV]) {
+			module_put(type->owner);
+			return -EOPNOTSUPP;
+		}
+
+		nla_strlcpy(ifname, ha[NFTA_HOOK_DEV], IFNAMSIZ);
+		dev = dev_get_by_name(net, ifname);
+		if (!dev) {
+			module_put(type->owner);
+			return -ENOENT;
+		}
+		hook->dev = dev;
+	} else if (ha[NFTA_HOOK_DEV]) {
+		module_put(type->owner);
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static void nft_chain_release_hook(struct nft_chain_hook *hook)
+{
+	module_put(hook->type->owner);
+	if (hook->dev != NULL)
+		dev_put(hook->dev);
+}
+
 static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 			      struct sk_buff *skb, const struct nlmsghdr *nlh,
 			      const struct nlattr * const nla[])
@@ -1206,10 +1283,8 @@ static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 	struct nft_table *table;
 	struct nft_chain *chain;
 	struct nft_base_chain *basechain = NULL;
-	struct nlattr *ha[NFTA_HOOK_MAX + 1];
 	u8 genmask = nft_genmask_next(net);
 	int family = nfmsg->nfgen_family;
-	struct net_device *dev = NULL;
 	u8 policy = NF_ACCEPT;
 	u64 handle = 0;
 	unsigned int i;
@@ -1320,102 +1395,53 @@ static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 		return -EOVERFLOW;
 
 	if (nla[NFTA_CHAIN_HOOK]) {
-		const struct nf_chain_type *type;
+		struct nft_chain_hook hook;
 		struct nf_hook_ops *ops;
 		nf_hookfn *hookfn;
-		u32 hooknum, priority;
-
-		type = chain_type[family][NFT_CHAIN_T_DEFAULT];
-		if (nla[NFTA_CHAIN_TYPE]) {
-			type = nf_tables_chain_type_lookup(afi,
-							   nla[NFTA_CHAIN_TYPE],
-							   create);
-			if (IS_ERR(type))
-				return PTR_ERR(type);
-		}
 
-		err = nla_parse_nested(ha, NFTA_HOOK_MAX, nla[NFTA_CHAIN_HOOK],
-				       nft_hook_policy);
+		err = nft_chain_parse_hook(net, nla, afi, &hook, create);
 		if (err < 0)
 			return err;
-		if (ha[NFTA_HOOK_HOOKNUM] == NULL ||
-		    ha[NFTA_HOOK_PRIORITY] == NULL)
-			return -EINVAL;
-
-		hooknum = ntohl(nla_get_be32(ha[NFTA_HOOK_HOOKNUM]));
-		if (hooknum >= afi->nhooks)
-			return -EINVAL;
-		priority = ntohl(nla_get_be32(ha[NFTA_HOOK_PRIORITY]));
-
-		if (!(type->hook_mask & (1 << hooknum)))
-			return -EOPNOTSUPP;
-		if (!try_module_get(type->owner))
-			return -ENOENT;
-		hookfn = type->hooks[hooknum];
-
-		if (afi->flags & NFT_AF_NEEDS_DEV) {
-			char ifname[IFNAMSIZ];
-
-			if (!ha[NFTA_HOOK_DEV]) {
-				module_put(type->owner);
-				return -EOPNOTSUPP;
-			}
-
-			nla_strlcpy(ifname, ha[NFTA_HOOK_DEV], IFNAMSIZ);
-			dev = dev_get_by_name(net, ifname);
-			if (!dev) {
-				module_put(type->owner);
-				return -ENOENT;
-			}
-		} else if (ha[NFTA_HOOK_DEV]) {
-			module_put(type->owner);
-			return -EOPNOTSUPP;
-		}
 
 		basechain = kzalloc(sizeof(*basechain), GFP_KERNEL);
 		if (basechain == NULL) {
-			module_put(type->owner);
-			if (dev != NULL)
-				dev_put(dev);
+			nft_chain_release_hook(&hook);
 			return -ENOMEM;
 		}
 
-		if (dev != NULL)
-			strncpy(basechain->dev_name, dev->name, IFNAMSIZ);
+		if (hook.dev != NULL)
+			strncpy(basechain->dev_name, hook.dev->name, IFNAMSIZ);
 
 		if (nla[NFTA_CHAIN_COUNTERS]) {
 			stats = nft_stats_alloc(nla[NFTA_CHAIN_COUNTERS]);
 			if (IS_ERR(stats)) {
-				module_put(type->owner);
+				nft_chain_release_hook(&hook);
 				kfree(basechain);
-				if (dev != NULL)
-					dev_put(dev);
 				return PTR_ERR(stats);
 			}
 			basechain->stats = stats;
 		} else {
 			stats = netdev_alloc_pcpu_stats(struct nft_stats);
 			if (stats == NULL) {
-				module_put(type->owner);
+				nft_chain_release_hook(&hook);
 				kfree(basechain);
-				if (dev != NULL)
-					dev_put(dev);
 				return -ENOMEM;
 			}
 			rcu_assign_pointer(basechain->stats, stats);
 		}
 
-		basechain->type = type;
+		hookfn = hook.type->hooks[hook.num];
+		basechain->type = hook.type;
 		chain = &basechain->chain;
 
 		for (i = 0; i < afi->nops; i++) {
 			ops = &basechain->ops[i];
 			ops->pf		= family;
-			ops->hooknum	= hooknum;
-			ops->priority	= priority;
+			ops->hooknum	= hook.num;
+			ops->priority	= hook.priority;
 			ops->priv	= chain;
 			ops->hook	= afi->hooks[ops->hooknum];
-			ops->dev	= dev;
+			ops->dev	= hook.dev;
 			if (hookfn)
 				ops->hook = hookfn;
 			if (afi->hook_ops_init)
-- 
2.1.4
