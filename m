From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/7] netfilter: nf_tables: allow to bind table to net_device
Date: Fri, 10 Apr 2015 14:15:41 +0200
Message-ID: <1428668142-4006-7-git-send-email-pablo@netfilter.org>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
Cc: kaber@trash.net, netdev@vger.kernel.org, davem@davemloft.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40114 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755963AbbDJMLs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 08:11:48 -0400
In-Reply-To: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the NFT_AF_DEV flag that indicates that indicates that you need
to attach this table to a given net_device.

This is required by a follow up patch that introduces netdev tables that contain
ingress chains.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |    8 +++++
 include/uapi/linux/netfilter/nf_tables.h |    2 ++
 net/netfilter/nf_tables_api.c            |   47 ++++++++++++++++++++++++++----
 3 files changed, 52 insertions(+), 5 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index d6a2f0e..aab6e13 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -776,6 +776,7 @@ unsigned int nft_do_chain(struct nft_pktinfo *pkt,
  *	@use: number of chain references to this table
  *	@flags: table flag (see enum nft_table_flags)
  *	@name: name of the table
+ *	@dev: this table is bound to a device (if any)
  */
 struct nft_table {
 	struct list_head		list;
@@ -785,6 +786,11 @@ struct nft_table {
 	u32				use;
 	u16				flags;
 	char				name[NFT_TABLE_MAXNAMELEN];
+	struct net_device		*dev;
+};
+
+enum nft_af_flags {
+	NFT_AF_DEV	= (1 << 0),
 };
 
 /**
@@ -794,6 +800,7 @@ struct nft_table {
  *	@family: address family
  *	@nhooks: number of hooks in this family
  *	@owner: module owner
+ *	@flags: family flags
  *	@tables: used internally
  *	@nops: number of hook ops in this family
  *	@hook_ops_init: initialization function for chain hook ops
@@ -804,6 +811,7 @@ struct nft_af_info {
 	int				family;
 	unsigned int			nhooks;
 	struct module			*owner;
+	u32				flags;
 	struct list_head		tables;
 	unsigned int			nops;
 	void				(*hook_ops_init)(struct nf_hook_ops *,
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 05ee1e0..3859d56 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -117,12 +117,14 @@ enum nft_table_flags {
  * @NFTA_TABLE_NAME: name of the table (NLA_STRING)
  * @NFTA_TABLE_FLAGS: bitmask of enum nft_table_flags (NLA_U32)
  * @NFTA_TABLE_USE: number of chains in this table (NLA_U32)
+ * @NFTA_TABLE_DEV: net device name (NLA_STRING)
  */
 enum nft_table_attributes {
 	NFTA_TABLE_UNSPEC,
 	NFTA_TABLE_NAME,
 	NFTA_TABLE_FLAGS,
 	NFTA_TABLE_USE,
+	NFTA_TABLE_DEV,
 	__NFTA_TABLE_MAX
 };
 #define NFTA_TABLE_MAX		(__NFTA_TABLE_MAX - 1)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 0b96fa0..4d3a157 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -399,6 +399,8 @@ static const struct nla_policy nft_table_policy[NFTA_TABLE_MAX + 1] = {
 	[NFTA_TABLE_NAME]	= { .type = NLA_STRING,
 				    .len = NFT_TABLE_MAXNAMELEN - 1 },
 	[NFTA_TABLE_FLAGS]	= { .type = NLA_U32 },
+	[NFTA_TABLE_DEV]	= { .type = NLA_STRING,
+				    .len = IFNAMSIZ - 1 },
 };
 
 static int nf_tables_fill_table_info(struct sk_buff *skb, struct net *net,
@@ -423,6 +425,10 @@ static int nf_tables_fill_table_info(struct sk_buff *skb, struct net *net,
 	    nla_put_be32(skb, NFTA_TABLE_USE, htonl(table->use)))
 		goto nla_put_failure;
 
+	if (table->dev &&
+	    nla_put_string(skb, NFTA_TABLE_DEV, table->dev->name))
+		goto nla_put_failure;
+
 	nlmsg_end(skb, nlh);
 	return 0;
 
@@ -608,6 +614,11 @@ static int nf_tables_updtable(struct nft_ctx *ctx)
 	if (flags == ctx->table->flags)
 		return 0;
 
+	if ((ctx->afi->flags & NFT_AF_DEV) &&
+	    ctx->nla[NFTA_TABLE_DEV] &&
+	    nla_strcmp(ctx->nla[NFTA_TABLE_DEV], ctx->table->dev->name))
+		return -EBUSY;
+
 	trans = nft_trans_alloc(ctx, NFT_MSG_NEWTABLE,
 				sizeof(struct nft_trans_table));
 	if (trans == NULL)
@@ -645,6 +656,7 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 	struct nft_table *table;
 	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
+	struct net_device *dev = NULL;
 	u32 flags = 0;
 	struct nft_ctx ctx;
 	int err;
@@ -679,30 +691,51 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 			return -EINVAL;
 	}
 
+	if (afi->flags & NFT_AF_DEV) {
+		char ifname[IFNAMSIZ];
+
+		if (!nla[NFTA_TABLE_DEV])
+			return -EINVAL;
+
+		nla_strlcpy(ifname, nla[NFTA_TABLE_DEV], IFNAMSIZ);
+		dev = dev_get_by_name(net, ifname);
+		if (!dev)
+			return -ENOENT;
+	} else {
+		if (nla[NFTA_TABLE_DEV])
+			return -EINVAL;
+	}
+
+	err = -EAFNOSUPPORT;
 	if (!try_module_get(afi->owner))
-		return -EAFNOSUPPORT;
+		goto err1;
 
 	err = -ENOMEM;
 	table = kzalloc(sizeof(*table), GFP_KERNEL);
 	if (table == NULL)
-		goto err1;
+		goto err2;
 
 	nla_strlcpy(table->name, name, NFT_TABLE_MAXNAMELEN);
 	INIT_LIST_HEAD(&table->chains);
 	INIT_LIST_HEAD(&table->sets);
 	table->flags = flags;
+	table->dev   = dev;
 
 	nft_ctx_init(&ctx, skb, nlh, afi, table, NULL, nla);
 	err = nft_trans_table_add(&ctx, NFT_MSG_NEWTABLE);
 	if (err < 0)
-		goto err2;
+		goto err3;
 
 	list_add_tail_rcu(&table->list, &afi->tables);
 	return 0;
-err2:
+err3:
 	kfree(table);
-err1:
+err2:
 	module_put(afi->owner);
+err1:
+	if (dev != NULL)
+		dev_put(dev);
+
 	return err;
 }
 
@@ -806,6 +839,9 @@ static void nf_tables_table_destroy(struct nft_ctx *ctx)
 {
 	BUG_ON(ctx->table->use > 0);
 
+	if (ctx->table->dev)
+		dev_put(ctx->table->dev);
+
 	kfree(ctx->table);
 	module_put(ctx->afi->owner);
 }
@@ -1361,6 +1397,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 			ops->priority	= priority;
 			ops->priv	= chain;
 			ops->hook	= afi->hooks[ops->hooknum];
+			ops->dev	= table->dev;
 			if (hookfn)
 				ops->hook = hookfn;
 			if (afi->hook_ops_init)
-- 
1.7.10.4
