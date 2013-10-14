From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/17] netfilter: nf_tables: complete net namespace support
Date: Mon, 14 Oct 2013 18:38:54 +0200
Message-ID: <1381768738-17739-14-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Register family per netnamespace to ensure that sets are
only visible in its approapriate namespace.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/net_namespace.h             |    4 ++
 include/net/netfilter/nf_tables.h       |    4 +-
 include/net/netns/nftables.h            |   15 ++++++
 net/bridge/netfilter/nf_tables_bridge.c |   32 +++++++++++-
 net/ipv4/netfilter/nf_tables_ipv4.c     |   32 +++++++++++-
 net/ipv6/netfilter/nf_tables_ipv6.c     |   33 +++++++++++-
 net/netfilter/nf_tables_api.c           |   83 ++++++++++++++++++++-----------
 7 files changed, 168 insertions(+), 35 deletions(-)
 create mode 100644 include/net/netns/nftables.h

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index bcc4a8e..da68c9a 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -22,6 +22,7 @@
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netns/conntrack.h>
 #endif
+#include <net/netns/nftables.h>
 #include <net/netns/xfrm.h>
 
 struct user_namespace;
@@ -101,6 +102,9 @@ struct net {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	struct netns_ct		ct;
 #endif
+#if defined(CONFIG_NF_TABLES) || defined(CONFIG_NF_TABLES_MODULE)
+	struct netns_nftables	nft;
+#endif
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
 	struct netns_nf_frag	nf_frag;
 #endif
diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index a68f45f..d3272e9 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -68,6 +68,7 @@ static inline void nft_data_debug(const struct nft_data *data)
 /**
  *	struct nft_ctx - nf_tables rule/set context
  *
+ *	@net: net namespace
  * 	@skb: netlink skb
  * 	@nlh: netlink message header
  * 	@afi: address family info
@@ -76,6 +77,7 @@ static inline void nft_data_debug(const struct nft_data *data)
  *	@nla: netlink attributes
  */
 struct nft_ctx {
+	struct net			*net;
 	const struct sk_buff		*skb;
 	const struct nlmsghdr		*nlh;
 	const struct nft_af_info	*afi;
@@ -462,7 +464,7 @@ struct nft_af_info {
 	nf_hookfn			*hooks[NF_MAX_HOOKS];
 };
 
-extern int nft_register_afinfo(struct nft_af_info *);
+extern int nft_register_afinfo(struct net *, struct nft_af_info *);
 extern void nft_unregister_afinfo(struct nft_af_info *);
 
 struct nf_chain_type {
diff --git a/include/net/netns/nftables.h b/include/net/netns/nftables.h
new file mode 100644
index 0000000..a98b1c5
--- /dev/null
+++ b/include/net/netns/nftables.h
@@ -0,0 +1,15 @@
+#ifndef _NETNS_NFTABLES_H_
+#define _NETNS_NFTABLES_H_
+
+#include <linux/list.h>
+
+struct nft_af_info;
+
+struct netns_nftables {
+	struct list_head	af_info;
+	struct nft_af_info	*ipv4;
+	struct nft_af_info	*ipv6;
+	struct nft_af_info	*bridge;
+};
+
+#endif
diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index bc5c21c..e8cb016 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -19,14 +19,42 @@ static struct nft_af_info nft_af_bridge __read_mostly = {
 	.owner		= THIS_MODULE,
 };
 
+static int nf_tables_bridge_init_net(struct net *net)
+{
+	net->nft.bridge = kmalloc(sizeof(struct nft_af_info), GFP_KERNEL);
+	if (net->nft.bridge == NULL)
+		return -ENOMEM;
+
+	memcpy(net->nft.bridge, &nft_af_bridge, sizeof(nft_af_bridge));
+
+	if (nft_register_afinfo(net, net->nft.bridge) < 0)
+		goto err;
+
+	return 0;
+err:
+	kfree(net->nft.bridge);
+	return -ENOMEM;
+}
+
+static void nf_tables_bridge_exit_net(struct net *net)
+{
+	nft_unregister_afinfo(net->nft.bridge);
+	kfree(net->nft.bridge);
+}
+
+static struct pernet_operations nf_tables_bridge_net_ops = {
+	.init	= nf_tables_bridge_init_net,
+	.exit	= nf_tables_bridge_exit_net,
+};
+
 static int __init nf_tables_bridge_init(void)
 {
-	return nft_register_afinfo(&nft_af_bridge);
+	return register_pernet_subsys(&nf_tables_bridge_net_ops);
 }
 
 static void __exit nf_tables_bridge_exit(void)
 {
-	nft_unregister_afinfo(&nft_af_bridge);
+	return unregister_pernet_subsys(&nf_tables_bridge_net_ops);
 }
 
 module_init(nf_tables_bridge_init);
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index c61cffb..8f7536b 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -14,6 +14,7 @@
 #include <linux/ip.h>
 #include <linux/netfilter_ipv4.h>
 #include <net/netfilter/nf_tables.h>
+#include <net/net_namespace.h>
 #include <net/ip.h>
 #include <net/net_namespace.h>
 #include <net/netfilter/nf_tables_ipv4.h>
@@ -47,6 +48,33 @@ static struct nft_af_info nft_af_ipv4 __read_mostly = {
 	},
 };
 
+static int nf_tables_ipv4_init_net(struct net *net)
+{
+	net->nft.ipv4 = kmalloc(sizeof(struct nft_af_info), GFP_KERNEL);
+	if (net->nft.ipv4 == NULL)
+		return -ENOMEM;
+
+	memcpy(net->nft.ipv4, &nft_af_ipv4, sizeof(nft_af_ipv4));
+
+	if (nft_register_afinfo(net, net->nft.ipv4) < 0)
+		goto err;
+
+	return 0;
+err:
+	kfree(net->nft.ipv4);
+	return -ENOMEM;
+}
+
+static void nf_tables_ipv4_exit_net(struct net *net)
+{
+	nft_unregister_afinfo(net->nft.ipv4);
+	kfree(net->nft.ipv4);
+}
+
+static struct pernet_operations nf_tables_ipv4_net_ops = {
+	.init	= nf_tables_ipv4_init_net,
+	.exit	= nf_tables_ipv4_exit_net,
+};
 
 static unsigned int
 nft_do_chain_ipv4(const struct nf_hook_ops *ops,
@@ -83,12 +111,12 @@ static struct nf_chain_type filter_ipv4 = {
 static int __init nf_tables_ipv4_init(void)
 {
 	nft_register_chain_type(&filter_ipv4);
-	return nft_register_afinfo(&nft_af_ipv4);
+	return register_pernet_subsys(&nf_tables_ipv4_net_ops);
 }
 
 static void __exit nf_tables_ipv4_exit(void)
 {
-	nft_unregister_afinfo(&nft_af_ipv4);
+	unregister_pernet_subsys(&nf_tables_ipv4_net_ops);
 	nft_unregister_chain_type(&filter_ipv4);
 }
 
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index 42f905a..d77db8a 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -45,6 +45,34 @@ static struct nft_af_info nft_af_ipv6 __read_mostly = {
 	},
 };
 
+static int nf_tables_ipv6_init_net(struct net *net)
+{
+	net->nft.ipv6 = kmalloc(sizeof(struct nft_af_info), GFP_KERNEL);
+	if (net->nft.ipv6 == NULL)
+		return -ENOMEM;
+
+	memcpy(net->nft.ipv6, &nft_af_ipv6, sizeof(nft_af_ipv6));
+
+	if (nft_register_afinfo(net, net->nft.ipv6) < 0)
+		goto err;
+
+	return 0;
+err:
+	kfree(net->nft.ipv6);
+	return -ENOMEM;
+}
+
+static void nf_tables_ipv6_exit_net(struct net *net)
+{
+	nft_unregister_afinfo(net->nft.ipv6);
+	kfree(net->nft.ipv6);
+}
+
+static struct pernet_operations nf_tables_ipv6_net_ops = {
+	.init	= nf_tables_ipv6_init_net,
+	.exit	= nf_tables_ipv6_exit_net,
+};
+
 static unsigned int
 nft_do_chain_ipv6(const struct nf_hook_ops *ops,
 		  struct sk_buff *skb,
@@ -82,11 +110,12 @@ static struct nf_chain_type filter_ipv6 = {
 static int __init nf_tables_ipv6_init(void)
 {
 	nft_register_chain_type(&filter_ipv6);
-	return nft_register_afinfo(&nft_af_ipv6);
+	return register_pernet_subsys(&nf_tables_ipv6_net_ops);
 }
+
 static void __exit nf_tables_ipv6_exit(void)
 {
-	nft_unregister_afinfo(&nft_af_ipv6);
+	unregister_pernet_subsys(&nf_tables_ipv6_net_ops);
 	nft_unregister_chain_type(&filter_ipv6);
 }
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index a4dd7ce..e1ee850 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -18,9 +18,9 @@
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables_core.h>
 #include <net/netfilter/nf_tables.h>
+#include <net/net_namespace.h>
 #include <net/sock.h>
 
-static LIST_HEAD(nf_tables_afinfo);
 static LIST_HEAD(nf_tables_expressions);
 
 /**
@@ -31,11 +31,11 @@ static LIST_HEAD(nf_tables_expressions);
  *	Register the address family for use with nf_tables. Returns zero on
  *	success or a negative errno code otherwise.
  */
-int nft_register_afinfo(struct nft_af_info *afi)
+int nft_register_afinfo(struct net *net, struct nft_af_info *afi)
 {
 	INIT_LIST_HEAD(&afi->tables);
 	nfnl_lock(NFNL_SUBSYS_NFTABLES);
-	list_add_tail(&afi->list, &nf_tables_afinfo);
+	list_add_tail(&afi->list, &net->nft.af_info);
 	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
 	return 0;
 }
@@ -56,22 +56,23 @@ void nft_unregister_afinfo(struct nft_af_info *afi)
 }
 EXPORT_SYMBOL_GPL(nft_unregister_afinfo);
 
-static struct nft_af_info *nft_afinfo_lookup(int family)
+static struct nft_af_info *nft_afinfo_lookup(struct net *net, int family)
 {
 	struct nft_af_info *afi;
 
-	list_for_each_entry(afi, &nf_tables_afinfo, list) {
+	list_for_each_entry(afi, &net->nft.af_info, list) {
 		if (afi->family == family)
 			return afi;
 	}
 	return NULL;
 }
 
-static struct nft_af_info *nf_tables_afinfo_lookup(int family, bool autoload)
+static struct nft_af_info *
+nf_tables_afinfo_lookup(struct net *net, int family, bool autoload)
 {
 	struct nft_af_info *afi;
 
-	afi = nft_afinfo_lookup(family);
+	afi = nft_afinfo_lookup(net, family);
 	if (afi != NULL)
 		return afi;
 #ifdef CONFIG_MODULES
@@ -79,7 +80,7 @@ static struct nft_af_info *nf_tables_afinfo_lookup(int family, bool autoload)
 		nfnl_unlock(NFNL_SUBSYS_NFTABLES);
 		request_module("nft-afinfo-%u", family);
 		nfnl_lock(NFNL_SUBSYS_NFTABLES);
-		afi = nft_afinfo_lookup(family);
+		afi = nft_afinfo_lookup(net, family);
 		if (afi != NULL)
 			return ERR_PTR(-EAGAIN);
 	}
@@ -232,9 +233,10 @@ static int nf_tables_dump_tables(struct sk_buff *skb,
 	const struct nft_af_info *afi;
 	const struct nft_table *table;
 	unsigned int idx = 0, s_idx = cb->args[0];
+	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 
-	list_for_each_entry(afi, &nf_tables_afinfo, list) {
+	list_for_each_entry(afi, &net->nft.af_info, list) {
 		if (family != NFPROTO_UNSPEC && family != afi->family)
 			continue;
 
@@ -268,6 +270,7 @@ static int nf_tables_gettable(struct sock *nlsk, struct sk_buff *skb,
 	const struct nft_af_info *afi;
 	const struct nft_table *table;
 	struct sk_buff *skb2;
+	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 	int err;
 
@@ -278,7 +281,7 @@ static int nf_tables_gettable(struct sock *nlsk, struct sk_buff *skb,
 		return netlink_dump_start(nlsk, skb, nlh, &c);
 	}
 
-	afi = nf_tables_afinfo_lookup(family, false);
+	afi = nf_tables_afinfo_lookup(net, family, false);
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
@@ -379,9 +382,10 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 	const struct nlattr *name;
 	struct nft_af_info *afi;
 	struct nft_table *table;
+	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 
-	afi = nf_tables_afinfo_lookup(family, true);
+	afi = nf_tables_afinfo_lookup(net, family, true);
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
@@ -433,9 +437,10 @@ static int nf_tables_deltable(struct sock *nlsk, struct sk_buff *skb,
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	struct nft_af_info *afi;
 	struct nft_table *table;
+	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 
-	afi = nf_tables_afinfo_lookup(family, false);
+	afi = nf_tables_afinfo_lookup(net, family, false);
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
@@ -663,9 +668,10 @@ static int nf_tables_dump_chains(struct sk_buff *skb,
 	const struct nft_table *table;
 	const struct nft_chain *chain;
 	unsigned int idx = 0, s_idx = cb->args[0];
+	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 
-	list_for_each_entry(afi, &nf_tables_afinfo, list) {
+	list_for_each_entry(afi, &net->nft.af_info, list) {
 		if (family != NFPROTO_UNSPEC && family != afi->family)
 			continue;
 
@@ -702,6 +708,7 @@ static int nf_tables_getchain(struct sock *nlsk, struct sk_buff *skb,
 	const struct nft_table *table;
 	const struct nft_chain *chain;
 	struct sk_buff *skb2;
+	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 	int err;
 
@@ -712,7 +719,7 @@ static int nf_tables_getchain(struct sock *nlsk, struct sk_buff *skb,
 		return netlink_dump_start(nlsk, skb, nlh, &c);
 	}
 
-	afi = nf_tables_afinfo_lookup(family, false);
+	afi = nf_tables_afinfo_lookup(net, family, false);
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
@@ -813,6 +820,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 	struct nft_chain *chain;
 	struct nft_base_chain *basechain = NULL;
 	struct nlattr *ha[NFTA_HOOK_MAX + 1];
+	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 	u64 handle = 0;
 	int err;
@@ -820,7 +828,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 
 	create = nlh->nlmsg_flags & NLM_F_CREATE ? true : false;
 
-	afi = nf_tables_afinfo_lookup(family, true);
+	afi = nf_tables_afinfo_lookup(net, family, true);
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
@@ -1010,9 +1018,10 @@ static int nf_tables_delchain(struct sock *nlsk, struct sk_buff *skb,
 	const struct nft_af_info *afi;
 	struct nft_table *table;
 	struct nft_chain *chain;
+	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 
-	afi = nf_tables_afinfo_lookup(family, false);
+	afi = nf_tables_afinfo_lookup(net, family, false);
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
@@ -1050,6 +1059,7 @@ static void nft_ctx_init(struct nft_ctx *ctx,
 			 const struct nft_chain *chain,
 			 const struct nlattr * const *nla)
 {
+	ctx->net   = sock_net(skb->sk);
 	ctx->skb   = skb;
 	ctx->nlh   = nlh;
 	ctx->afi   = afi;
@@ -1361,9 +1371,10 @@ static int nf_tables_dump_rules(struct sk_buff *skb,
 	const struct nft_chain *chain;
 	const struct nft_rule *rule;
 	unsigned int idx = 0, s_idx = cb->args[0];
+	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 
-	list_for_each_entry(afi, &nf_tables_afinfo, list) {
+	list_for_each_entry(afi, &net->nft.af_info, list) {
 		if (family != NFPROTO_UNSPEC && family != afi->family)
 			continue;
 
@@ -1402,6 +1413,7 @@ static int nf_tables_getrule(struct sock *nlsk, struct sk_buff *skb,
 	const struct nft_chain *chain;
 	const struct nft_rule *rule;
 	struct sk_buff *skb2;
+	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 	int err;
 
@@ -1412,7 +1424,7 @@ static int nf_tables_getrule(struct sock *nlsk, struct sk_buff *skb,
 		return netlink_dump_start(nlsk, skb, nlh, &c);
 	}
 
-	afi = nf_tables_afinfo_lookup(family, false);
+	afi = nf_tables_afinfo_lookup(net, family, false);
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
@@ -1477,6 +1489,7 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	const struct nft_af_info *afi;
+	struct net *net = sock_net(skb->sk);
 	struct nft_table *table;
 	struct nft_chain *chain;
 	struct nft_rule *rule, *old_rule = NULL;
@@ -1490,7 +1503,7 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 
 	create = nlh->nlmsg_flags & NLM_F_CREATE ? true : false;
 
-	afi = nf_tables_afinfo_lookup(nfmsg->nfgen_family, create);
+	afi = nf_tables_afinfo_lookup(net, nfmsg->nfgen_family, create);
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
@@ -1585,12 +1598,13 @@ static int nf_tables_delrule(struct sock *nlsk, struct sk_buff *skb,
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	const struct nft_af_info *afi;
+	struct net *net = sock_net(skb->sk);
 	const struct nft_table *table;
 	struct nft_chain *chain;
 	struct nft_rule *rule, *tmp;
 	int family = nfmsg->nfgen_family;
 
-	afi = nf_tables_afinfo_lookup(family, false);
+	afi = nf_tables_afinfo_lookup(net, family, false);
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
@@ -1697,11 +1711,12 @@ static int nft_ctx_init_from_setattr(struct nft_ctx *ctx,
 				     const struct nlmsghdr *nlh,
 				     const struct nlattr * const nla[])
 {
+	struct net *net = sock_net(skb->sk);
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	const struct nft_af_info *afi;
 	const struct nft_table *table = NULL;
 
-	afi = nf_tables_afinfo_lookup(nfmsg->nfgen_family, false);
+	afi = nf_tables_afinfo_lookup(net, nfmsg->nfgen_family, false);
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
@@ -1818,12 +1833,11 @@ static int nf_tables_set_notify(const struct nft_ctx *ctx,
 {
 	struct sk_buff *skb;
 	u32 portid = NETLINK_CB(ctx->skb).portid;
-	struct net *net = sock_net(ctx->skb->sk);
 	bool report;
 	int err;
 
 	report = nlmsg_report(ctx->nlh);
-	if (!report && !nfnetlink_has_listeners(net, NFNLGRP_NFTABLES))
+	if (!report && !nfnetlink_has_listeners(ctx->net, NFNLGRP_NFTABLES))
 		return 0;
 
 	err = -ENOBUFS;
@@ -1837,11 +1851,11 @@ static int nf_tables_set_notify(const struct nft_ctx *ctx,
 		goto err;
 	}
 
-	err = nfnetlink_send(skb, net, portid, NFNLGRP_NFTABLES, report,
+	err = nfnetlink_send(skb, ctx->net, portid, NFNLGRP_NFTABLES, report,
 			     GFP_KERNEL);
 err:
 	if (err < 0)
-		nfnetlink_set_err(net, portid, NFNLGRP_NFTABLES, err);
+		nfnetlink_set_err(ctx->net, portid, NFNLGRP_NFTABLES, err);
 	return err;
 }
 
@@ -1974,6 +1988,7 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	const struct nft_set_ops *ops;
 	const struct nft_af_info *afi;
+	struct net *net = sock_net(skb->sk);
 	struct nft_table *table;
 	struct nft_set *set;
 	struct nft_ctx ctx;
@@ -2032,7 +2047,7 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 
 	create = nlh->nlmsg_flags & NLM_F_CREATE ? true : false;
 
-	afi = nf_tables_afinfo_lookup(nfmsg->nfgen_family, create);
+	afi = nf_tables_afinfo_lookup(net, nfmsg->nfgen_family, create);
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
@@ -2219,8 +2234,9 @@ static int nft_ctx_init_from_elemattr(struct nft_ctx *ctx,
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	const struct nft_af_info *afi;
 	const struct nft_table *table;
+	struct net *net = sock_net(skb->sk);
 
-	afi = nf_tables_afinfo_lookup(nfmsg->nfgen_family, false);
+	afi = nf_tables_afinfo_lookup(net, nfmsg->nfgen_family, false);
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
@@ -3011,6 +3027,16 @@ int nft_data_dump(struct sk_buff *skb, int attr, const struct nft_data *data,
 }
 EXPORT_SYMBOL_GPL(nft_data_dump);
 
+static int nf_tables_init_net(struct net *net)
+{
+	INIT_LIST_HEAD(&net->nft.af_info);
+	return 0;
+}
+
+static struct pernet_operations nf_tables_net_ops = {
+	.init	= nf_tables_init_net,
+};
+
 static int __init nf_tables_module_init(void)
 {
 	int err;
@@ -3031,7 +3057,7 @@ static int __init nf_tables_module_init(void)
 		goto err3;
 
 	pr_info("nf_tables: (c) 2007-2009 Patrick McHardy <kaber@trash.net>\n");
-	return 0;
+	return register_pernet_subsys(&nf_tables_net_ops);
 err3:
 	nf_tables_core_module_exit();
 err2:
@@ -3042,6 +3068,7 @@ err1:
 
 static void __exit nf_tables_module_exit(void)
 {
+	unregister_pernet_subsys(&nf_tables_net_ops);
 	nfnetlink_subsys_unregister(&nf_tables_subsys);
 	nf_tables_core_module_exit();
 	kfree(info);
-- 
1.7.10.4

