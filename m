From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 32/32] netfilter: nf_tables_netdev: unregister hooks on net_device removal
Date: Mon, 15 Jun 2015 23:26:29 +0200
Message-ID: <1434403589-24796-33-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58874 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932221AbbFOVVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 17:21:43 -0400
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case the net_device is gone, we have to unregister the hooks and put back
the reference on the net_device object. Once it comes back, register them
again. This also covers the device rename case.

This patch also adds a new flag to indicate that the basechain is disabled, so
their hooks are not registered. This flag is used by the netdev family to
handle the case where the net_device object is gone. Currently this flag is not
exposed to userspace.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    7 ++++
 net/netfilter/nf_tables_api.c     |   16 ++++++--
 net/netfilter/nf_tables_netdev.c  |   75 +++++++++++++++++++++++++++++++++++++
 3 files changed, 94 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 09d6f8d..2a24668 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -781,6 +781,7 @@ struct nft_stats {
 };
 
 #define NFT_HOOK_OPS_MAX		2
+#define NFT_BASECHAIN_DISABLED		(1 << 0)
 
 /**
  *	struct nft_base_chain - nf_tables base chain
@@ -798,6 +799,7 @@ struct nft_base_chain {
 	possible_net_t			pnet;
 	const struct nf_chain_type	*type;
 	u8				policy;
+	u8				flags;
 	struct nft_stats __percpu	*stats;
 	struct nft_chain		chain;
 	char 				dev_name[IFNAMSIZ];
@@ -808,6 +810,11 @@ static inline struct nft_base_chain *nft_base_chain(const struct nft_chain *chai
 	return container_of(chain, struct nft_base_chain, chain);
 }
 
+int nft_register_basechain(struct nft_base_chain *basechain,
+			   unsigned int hook_nops);
+void nft_unregister_basechain(struct nft_base_chain *basechain,
+			      unsigned int hook_nops);
+
 unsigned int nft_do_chain(struct nft_pktinfo *pkt,
 			  const struct nf_hook_ops *ops);
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index c66dc62..cfe6368 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -127,17 +127,25 @@ static void nft_trans_destroy(struct nft_trans *trans)
 	kfree(trans);
 }
 
-static int nft_register_basechain(struct nft_base_chain *basechain,
-				  unsigned int hook_nops)
+int nft_register_basechain(struct nft_base_chain *basechain,
+			   unsigned int hook_nops)
 {
+	if (basechain->flags & NFT_BASECHAIN_DISABLED)
+		return 0;
+
 	return nf_register_hooks(basechain->ops, hook_nops);
 }
+EXPORT_SYMBOL_GPL(nft_register_basechain);
 
-static void nft_unregister_basechain(struct nft_base_chain *basechain,
-				     unsigned int hook_nops)
+void nft_unregister_basechain(struct nft_base_chain *basechain,
+			      unsigned int hook_nops)
 {
+	if (basechain->flags & NFT_BASECHAIN_DISABLED)
+		return;
+
 	nf_unregister_hooks(basechain->ops, hook_nops);
 }
+EXPORT_SYMBOL_GPL(nft_unregister_basechain);
 
 static int nf_tables_register_hooks(const struct nft_table *table,
 				    struct nft_chain *chain,
diff --git a/net/netfilter/nf_tables_netdev.c b/net/netfilter/nf_tables_netdev.c
index 04cb170..2cae4d4 100644
--- a/net/netfilter/nf_tables_netdev.c
+++ b/net/netfilter/nf_tables_netdev.c
@@ -8,6 +8,7 @@
 
 #include <linux/init.h>
 #include <linux/module.h>
+#include <linux/netdevice.h>
 #include <net/netfilter/nf_tables.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
@@ -157,6 +158,77 @@ static const struct nf_chain_type nft_filter_chain_netdev = {
 	.hook_mask	= (1 << NF_NETDEV_INGRESS),
 };
 
+static void nft_netdev_event(unsigned long event, struct nft_af_info *afi,
+			     struct net_device *dev, struct nft_table *table,
+			     struct nft_base_chain *basechain)
+{
+	switch (event) {
+	case NETDEV_REGISTER:
+		if (strcmp(basechain->dev_name, dev->name) != 0)
+			return;
+
+		BUG_ON(!(basechain->flags & NFT_BASECHAIN_DISABLED));
+
+		dev_hold(dev);
+		basechain->ops[0].dev = dev;
+		basechain->flags &= ~NFT_BASECHAIN_DISABLED;
+		if (!(table->flags & NFT_TABLE_F_DORMANT))
+			nft_register_basechain(basechain, afi->nops);
+		break;
+	case NETDEV_UNREGISTER:
+		if (strcmp(basechain->dev_name, dev->name) != 0)
+			return;
+
+		BUG_ON(basechain->flags & NFT_BASECHAIN_DISABLED);
+
+		if (!(table->flags & NFT_TABLE_F_DORMANT))
+			nft_unregister_basechain(basechain, afi->nops);
+
+		dev_put(basechain->ops[0].dev);
+		basechain->ops[0].dev = NULL;
+		basechain->flags |= NFT_BASECHAIN_DISABLED;
+		break;
+	case NETDEV_CHANGENAME:
+		if (dev->ifindex != basechain->ops[0].dev->ifindex)
+			return;
+
+		strncpy(basechain->dev_name, dev->name, IFNAMSIZ);
+		break;
+	}
+}
+
+static int nf_tables_netdev_event(struct notifier_block *this,
+				  unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct nft_af_info *afi;
+	struct nft_table *table;
+	struct nft_chain *chain;
+
+	nfnl_lock(NFNL_SUBSYS_NFTABLES);
+	list_for_each_entry(afi, &dev_net(dev)->nft.af_info, list) {
+		if (afi->family != NFPROTO_NETDEV)
+			continue;
+
+		list_for_each_entry(table, &afi->tables, list) {
+			list_for_each_entry(chain, &table->chains, list) {
+				if (!(chain->flags & NFT_BASE_CHAIN))
+					continue;
+
+				nft_netdev_event(event, afi, dev, table,
+						 nft_base_chain(chain));
+			}
+		}
+	}
+	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block nf_tables_netdev_notifier = {
+	.notifier_call	= nf_tables_netdev_event,
+};
+
 static int __init nf_tables_netdev_init(void)
 {
 	int ret;
@@ -166,11 +238,14 @@ static int __init nf_tables_netdev_init(void)
 	if (ret < 0)
 		nft_unregister_chain_type(&nft_filter_chain_netdev);
 
+	register_netdevice_notifier(&nf_tables_netdev_notifier);
+
 	return ret;
 }
 
 static void __exit nf_tables_netdev_exit(void)
 {
+	unregister_netdevice_notifier(&nf_tables_netdev_notifier);
 	unregister_pernet_subsys(&nf_tables_netdev_net_ops);
 	nft_unregister_chain_type(&nft_filter_chain_netdev);
 }
-- 
1.7.10.4
