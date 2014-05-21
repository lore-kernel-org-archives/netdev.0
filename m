From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/25] netfilter: nf_tables: remove skb and nlh from context structure
Date: Wed, 21 May 2014 11:43:21 +0200
Message-ID: <1400665402-5835-24-git-send-email-pablo@netfilter.org>
References: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of caching the original skbuff that contains the netlink
messages, this stores the netlink message sequence number, the
netlink portID and the report flag. This helps to prepare the
introduction of the object release via call_rcu.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |   10 ++--
 net/netfilter/nf_tables_api.c     |  101 +++++++++++++++++--------------------
 2 files changed, 52 insertions(+), 59 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index b08f2a9..1ed2797 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -72,21 +72,23 @@ static inline void nft_data_debug(const struct nft_data *data)
  *	struct nft_ctx - nf_tables rule/set context
  *
  *	@net: net namespace
- * 	@skb: netlink skb
- * 	@nlh: netlink message header
  * 	@afi: address family info
  * 	@table: the table the chain is contained in
  * 	@chain: the chain the rule is contained in
  *	@nla: netlink attributes
+ *	@portid: netlink portID of the original message
+ *	@seq: netlink sequence number
+ *	@report: notify via unicast netlink message
  */
 struct nft_ctx {
 	struct net			*net;
-	const struct sk_buff		*skb;
-	const struct nlmsghdr		*nlh;
 	struct nft_af_info		*afi;
 	struct nft_table		*table;
 	struct nft_chain		*chain;
 	const struct nlattr * const 	*nla;
+	u32				portid;
+	u32				seq;
+	bool				report;
 };
 
 struct nft_data_desc {
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 86d055a..4147166 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -96,13 +96,14 @@ static void nft_ctx_init(struct nft_ctx *ctx,
 			 struct nft_chain *chain,
 			 const struct nlattr * const *nla)
 {
-	ctx->net   = sock_net(skb->sk);
-	ctx->skb   = skb;
-	ctx->nlh   = nlh;
-	ctx->afi   = afi;
-	ctx->table = table;
-	ctx->chain = chain;
-	ctx->nla   = nla;
+	ctx->net	= sock_net(skb->sk);
+	ctx->afi	= afi;
+	ctx->table	= table;
+	ctx->chain	= chain;
+	ctx->nla   	= nla;
+	ctx->portid	= NETLINK_CB(skb).portid;
+	ctx->report	= nlmsg_report(nlh);
+	ctx->seq	= nlh->nlmsg_seq;
 }
 
 static struct nft_trans *nft_trans_alloc(struct nft_ctx *ctx, int msg_type,
@@ -238,14 +239,10 @@ nla_put_failure:
 static int nf_tables_table_notify(const struct nft_ctx *ctx, int event)
 {
 	struct sk_buff *skb;
-	u32 portid = NETLINK_CB(ctx->skb).portid;
-	u32 seq = ctx->nlh->nlmsg_seq;
-	struct net *net = sock_net(ctx->skb->sk);
-	bool report;
 	int err;
 
-	report = nlmsg_report(ctx->nlh);
-	if (!report && !nfnetlink_has_listeners(net, NFNLGRP_NFTABLES))
+	if (!ctx->report &&
+	    !nfnetlink_has_listeners(ctx->net, NFNLGRP_NFTABLES))
 		return 0;
 
 	err = -ENOBUFS;
@@ -253,18 +250,20 @@ static int nf_tables_table_notify(const struct nft_ctx *ctx, int event)
 	if (skb == NULL)
 		goto err;
 
-	err = nf_tables_fill_table_info(skb, portid, seq, event, 0,
+	err = nf_tables_fill_table_info(skb, ctx->portid, ctx->seq, event, 0,
 					ctx->afi->family, ctx->table);
 	if (err < 0) {
 		kfree_skb(skb);
 		goto err;
 	}
 
-	err = nfnetlink_send(skb, net, portid, NFNLGRP_NFTABLES, report,
-			     GFP_KERNEL);
+	err = nfnetlink_send(skb, ctx->net, ctx->portid, NFNLGRP_NFTABLES,
+			     ctx->report, GFP_KERNEL);
 err:
-	if (err < 0)
-		nfnetlink_set_err(net, portid, NFNLGRP_NFTABLES, err);
+	if (err < 0) {
+		nfnetlink_set_err(ctx->net, ctx->portid, NFNLGRP_NFTABLES,
+				  err);
+	}
 	return err;
 }
 
@@ -721,14 +720,10 @@ nla_put_failure:
 static int nf_tables_chain_notify(const struct nft_ctx *ctx, int event)
 {
 	struct sk_buff *skb;
-	u32 portid = NETLINK_CB(ctx->skb).portid;
-	struct net *net = sock_net(ctx->skb->sk);
-	u32 seq = ctx->nlh->nlmsg_seq;
-	bool report;
 	int err;
 
-	report = nlmsg_report(ctx->nlh);
-	if (!report && !nfnetlink_has_listeners(net, NFNLGRP_NFTABLES))
+	if (!ctx->report &&
+	    !nfnetlink_has_listeners(ctx->net, NFNLGRP_NFTABLES))
 		return 0;
 
 	err = -ENOBUFS;
@@ -736,7 +731,7 @@ static int nf_tables_chain_notify(const struct nft_ctx *ctx, int event)
 	if (skb == NULL)
 		goto err;
 
-	err = nf_tables_fill_chain_info(skb, portid, seq, event, 0,
+	err = nf_tables_fill_chain_info(skb, ctx->portid, ctx->seq, event, 0,
 					ctx->afi->family, ctx->table,
 					ctx->chain);
 	if (err < 0) {
@@ -744,11 +739,13 @@ static int nf_tables_chain_notify(const struct nft_ctx *ctx, int event)
 		goto err;
 	}
 
-	err = nfnetlink_send(skb, net, portid, NFNLGRP_NFTABLES, report,
-			     GFP_KERNEL);
+	err = nfnetlink_send(skb, ctx->net, ctx->portid, NFNLGRP_NFTABLES,
+			     ctx->report, GFP_KERNEL);
 err:
-	if (err < 0)
-		nfnetlink_set_err(net, portid, NFNLGRP_NFTABLES, err);
+	if (err < 0) {
+		nfnetlink_set_err(ctx->net, ctx->portid, NFNLGRP_NFTABLES,
+				  err);
+	}
 	return err;
 }
 
@@ -1473,16 +1470,11 @@ static int nf_tables_rule_notify(const struct nft_ctx *ctx,
 				 const struct nft_rule *rule,
 				 int event)
 {
-	const struct sk_buff *oskb = ctx->skb;
 	struct sk_buff *skb;
-	u32 portid = NETLINK_CB(oskb).portid;
-	struct net *net = sock_net(oskb->sk);
-	u32 seq = ctx->nlh->nlmsg_seq;
-	bool report;
 	int err;
 
-	report = nlmsg_report(ctx->nlh);
-	if (!report && !nfnetlink_has_listeners(net, NFNLGRP_NFTABLES))
+	if (!ctx->report &&
+	    !nfnetlink_has_listeners(ctx->net, NFNLGRP_NFTABLES))
 		return 0;
 
 	err = -ENOBUFS;
@@ -1490,7 +1482,7 @@ static int nf_tables_rule_notify(const struct nft_ctx *ctx,
 	if (skb == NULL)
 		goto err;
 
-	err = nf_tables_fill_rule_info(skb, portid, seq, event, 0,
+	err = nf_tables_fill_rule_info(skb, ctx->portid, ctx->seq, event, 0,
 				       ctx->afi->family, ctx->table,
 				       ctx->chain, rule);
 	if (err < 0) {
@@ -1498,11 +1490,13 @@ static int nf_tables_rule_notify(const struct nft_ctx *ctx,
 		goto err;
 	}
 
-	err = nfnetlink_send(skb, net, portid, NFNLGRP_NFTABLES, report,
-			     GFP_KERNEL);
+	err = nfnetlink_send(skb, ctx->net, ctx->portid, NFNLGRP_NFTABLES,
+			     ctx->report, GFP_KERNEL);
 err:
-	if (err < 0)
-		nfnetlink_set_err(net, portid, NFNLGRP_NFTABLES, err);
+	if (err < 0) {
+		nfnetlink_set_err(ctx->net, ctx->portid, NFNLGRP_NFTABLES,
+				  err);
+	}
 	return err;
 }
 
@@ -2141,8 +2135,8 @@ static int nf_tables_fill_set(struct sk_buff *skb, const struct nft_ctx *ctx,
 	struct nfgenmsg *nfmsg;
 	struct nlmsghdr *nlh;
 	struct nlattr *desc;
-	u32 portid = NETLINK_CB(ctx->skb).portid;
-	u32 seq = ctx->nlh->nlmsg_seq;
+	u32 portid = ctx->portid;
+	u32 seq = ctx->seq;
 
 	event |= NFNL_SUBSYS_NFTABLES << 8;
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct nfgenmsg),
@@ -2194,12 +2188,11 @@ static int nf_tables_set_notify(const struct nft_ctx *ctx,
 				int event)
 {
 	struct sk_buff *skb;
-	u32 portid = NETLINK_CB(ctx->skb).portid;
-	bool report;
+	u32 portid = ctx->portid;
 	int err;
 
-	report = nlmsg_report(ctx->nlh);
-	if (!report && !nfnetlink_has_listeners(ctx->net, NFNLGRP_NFTABLES))
+	if (!ctx->report &&
+	    !nfnetlink_has_listeners(ctx->net, NFNLGRP_NFTABLES))
 		return 0;
 
 	err = -ENOBUFS;
@@ -2213,8 +2206,8 @@ static int nf_tables_set_notify(const struct nft_ctx *ctx,
 		goto err;
 	}
 
-	err = nfnetlink_send(skb, ctx->net, portid, NFNLGRP_NFTABLES, report,
-			     GFP_KERNEL);
+	err = nfnetlink_send(skb, ctx->net, portid, NFNLGRP_NFTABLES,
+			     ctx->report, GFP_KERNEL);
 err:
 	if (err < 0)
 		nfnetlink_set_err(ctx->net, portid, NFNLGRP_NFTABLES, err);
@@ -2956,14 +2949,12 @@ static int nf_tables_setelem_notify(const struct nft_ctx *ctx,
 				    const struct nft_set_elem *elem,
 				    int event, u16 flags)
 {
-	const struct sk_buff *oskb = ctx->skb;
-	struct net *net = sock_net(oskb->sk);
-	u32 portid = NETLINK_CB(oskb).portid;
-	bool report = nlmsg_report(ctx->nlh);
+	struct net *net = ctx->net;
+	u32 portid = ctx->portid;
 	struct sk_buff *skb;
 	int err;
 
-	if (!report && !nfnetlink_has_listeners(net, NFNLGRP_NFTABLES))
+	if (!ctx->report && !nfnetlink_has_listeners(net, NFNLGRP_NFTABLES))
 		return 0;
 
 	err = -ENOBUFS;
@@ -2978,7 +2969,7 @@ static int nf_tables_setelem_notify(const struct nft_ctx *ctx,
 		goto err;
 	}
 
-	err = nfnetlink_send(skb, net, portid, NFNLGRP_NFTABLES, report,
+	err = nfnetlink_send(skb, net, portid, NFNLGRP_NFTABLES, ctx->report,
 			     GFP_KERNEL);
 err:
 	if (err < 0)
-- 
1.7.10.4

