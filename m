From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/4] netfilter: nf_tables: don't call nfnetlink_set_err() if nfnetlink_send() fails
Date: Fri,  3 Mar 2017 20:22:25 +0100
Message-ID: <1488568945-4177-5-git-send-email-pablo@netfilter.org>
References: <1488568945-4177-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39708 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752082AbdCCTXG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 14:23:06 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id F03EF1C501F
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 20:22:38 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DDA0BDA808
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 20:22:38 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 328E2DA80B
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 20:22:36 +0100 (CET)
In-Reply-To: <1488568945-4177-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The underlying nlmsg_multicast() already sets sk->sk_err for us to
notify socket overruns, so we should not do anything with this return
value. So we just call nfnetlink_set_err() if:

1) We fail to allocate the netlink message.

or

2) We don't have enough space in the netlink message to place attributes,
   which means that we likely need to allocate a larger message.

Before this patch, the internal ESRCH netlink error code was propagated
to userspace, which is quite misleading. Netlink semantics mandate that
listeners just hit ENOBUFS if the socket buffer overruns.

Reported-by: Alexander Alemayhu <alexander@alemayhu.com>
Tested-by: Alexander Alemayhu <alexander@alemayhu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |   6 +-
 net/netfilter/nf_tables_api.c     | 133 ++++++++++++++++----------------------
 2 files changed, 58 insertions(+), 81 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index ac84686aaafb..2aa8a9d80fbe 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -988,9 +988,9 @@ struct nft_object *nf_tables_obj_lookup(const struct nft_table *table,
 					const struct nlattr *nla, u32 objtype,
 					u8 genmask);
 
-int nft_obj_notify(struct net *net, struct nft_table *table,
-		   struct nft_object *obj, u32 portid, u32 seq,
-		   int event, int family, int report, gfp_t gfp);
+void nft_obj_notify(struct net *net, struct nft_table *table,
+		    struct nft_object *obj, u32 portid, u32 seq,
+		    int event, int family, int report, gfp_t gfp);
 
 /**
  *	struct nft_object_type - stateful object type
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index ff7304ae58ac..5e0ccfd5bb37 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -461,16 +461,15 @@ static int nf_tables_fill_table_info(struct sk_buff *skb, struct net *net,
 	return -1;
 }
 
-static int nf_tables_table_notify(const struct nft_ctx *ctx, int event)
+static void nf_tables_table_notify(const struct nft_ctx *ctx, int event)
 {
 	struct sk_buff *skb;
 	int err;
 
 	if (!ctx->report &&
 	    !nfnetlink_has_listeners(ctx->net, NFNLGRP_NFTABLES))
-		return 0;
+		return;
 
-	err = -ENOBUFS;
 	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (skb == NULL)
 		goto err;
@@ -482,14 +481,11 @@ static int nf_tables_table_notify(const struct nft_ctx *ctx, int event)
 		goto err;
 	}
 
-	err = nfnetlink_send(skb, ctx->net, ctx->portid, NFNLGRP_NFTABLES,
-			     ctx->report, GFP_KERNEL);
+	nfnetlink_send(skb, ctx->net, ctx->portid, NFNLGRP_NFTABLES,
+		       ctx->report, GFP_KERNEL);
+	return;
 err:
-	if (err < 0) {
-		nfnetlink_set_err(ctx->net, ctx->portid, NFNLGRP_NFTABLES,
-				  err);
-	}
-	return err;
+	nfnetlink_set_err(ctx->net, ctx->portid, NFNLGRP_NFTABLES, -ENOBUFS);
 }
 
 static int nf_tables_dump_tables(struct sk_buff *skb,
@@ -1050,16 +1046,15 @@ static int nf_tables_fill_chain_info(struct sk_buff *skb, struct net *net,
 	return -1;
 }
 
-static int nf_tables_chain_notify(const struct nft_ctx *ctx, int event)
+static void nf_tables_chain_notify(const struct nft_ctx *ctx, int event)
 {
 	struct sk_buff *skb;
 	int err;
 
 	if (!ctx->report &&
 	    !nfnetlink_has_listeners(ctx->net, NFNLGRP_NFTABLES))
-		return 0;
+		return;
 
-	err = -ENOBUFS;
 	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (skb == NULL)
 		goto err;
@@ -1072,14 +1067,11 @@ static int nf_tables_chain_notify(const struct nft_ctx *ctx, int event)
 		goto err;
 	}
 
-	err = nfnetlink_send(skb, ctx->net, ctx->portid, NFNLGRP_NFTABLES,
-			     ctx->report, GFP_KERNEL);
+	nfnetlink_send(skb, ctx->net, ctx->portid, NFNLGRP_NFTABLES,
+		       ctx->report, GFP_KERNEL);
+	return;
 err:
-	if (err < 0) {
-		nfnetlink_set_err(ctx->net, ctx->portid, NFNLGRP_NFTABLES,
-				  err);
-	}
-	return err;
+	nfnetlink_set_err(ctx->net, ctx->portid, NFNLGRP_NFTABLES, -ENOBUFS);
 }
 
 static int nf_tables_dump_chains(struct sk_buff *skb,
@@ -1934,18 +1926,16 @@ static int nf_tables_fill_rule_info(struct sk_buff *skb, struct net *net,
 	return -1;
 }
 
-static int nf_tables_rule_notify(const struct nft_ctx *ctx,
-				 const struct nft_rule *rule,
-				 int event)
+static void nf_tables_rule_notify(const struct nft_ctx *ctx,
+				  const struct nft_rule *rule, int event)
 {
 	struct sk_buff *skb;
 	int err;
 
 	if (!ctx->report &&
 	    !nfnetlink_has_listeners(ctx->net, NFNLGRP_NFTABLES))
-		return 0;
+		return;
 
-	err = -ENOBUFS;
 	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (skb == NULL)
 		goto err;
@@ -1958,14 +1948,11 @@ static int nf_tables_rule_notify(const struct nft_ctx *ctx,
 		goto err;
 	}
 
-	err = nfnetlink_send(skb, ctx->net, ctx->portid, NFNLGRP_NFTABLES,
-			     ctx->report, GFP_KERNEL);
+	nfnetlink_send(skb, ctx->net, ctx->portid, NFNLGRP_NFTABLES,
+		       ctx->report, GFP_KERNEL);
+	return;
 err:
-	if (err < 0) {
-		nfnetlink_set_err(ctx->net, ctx->portid, NFNLGRP_NFTABLES,
-				  err);
-	}
-	return err;
+	nfnetlink_set_err(ctx->net, ctx->portid, NFNLGRP_NFTABLES, -ENOBUFS);
 }
 
 struct nft_rule_dump_ctx {
@@ -2696,9 +2683,9 @@ static int nf_tables_fill_set(struct sk_buff *skb, const struct nft_ctx *ctx,
 	return -1;
 }
 
-static int nf_tables_set_notify(const struct nft_ctx *ctx,
-				const struct nft_set *set,
-				int event, gfp_t gfp_flags)
+static void nf_tables_set_notify(const struct nft_ctx *ctx,
+				 const struct nft_set *set, int event,
+			         gfp_t gfp_flags)
 {
 	struct sk_buff *skb;
 	u32 portid = ctx->portid;
@@ -2706,9 +2693,8 @@ static int nf_tables_set_notify(const struct nft_ctx *ctx,
 
 	if (!ctx->report &&
 	    !nfnetlink_has_listeners(ctx->net, NFNLGRP_NFTABLES))
-		return 0;
+		return;
 
-	err = -ENOBUFS;
 	skb = nlmsg_new(NLMSG_GOODSIZE, gfp_flags);
 	if (skb == NULL)
 		goto err;
@@ -2719,12 +2705,11 @@ static int nf_tables_set_notify(const struct nft_ctx *ctx,
 		goto err;
 	}
 
-	err = nfnetlink_send(skb, ctx->net, portid, NFNLGRP_NFTABLES,
-			     ctx->report, gfp_flags);
+	nfnetlink_send(skb, ctx->net, portid, NFNLGRP_NFTABLES, ctx->report,
+		       gfp_flags);
+	return;
 err:
-	if (err < 0)
-		nfnetlink_set_err(ctx->net, portid, NFNLGRP_NFTABLES, err);
-	return err;
+	nfnetlink_set_err(ctx->net, portid, NFNLGRP_NFTABLES, -ENOBUFS);
 }
 
 static int nf_tables_dump_sets(struct sk_buff *skb, struct netlink_callback *cb)
@@ -3504,10 +3489,10 @@ static int nf_tables_fill_setelem_info(struct sk_buff *skb,
 	return -1;
 }
 
-static int nf_tables_setelem_notify(const struct nft_ctx *ctx,
-				    const struct nft_set *set,
-				    const struct nft_set_elem *elem,
-				    int event, u16 flags)
+static void nf_tables_setelem_notify(const struct nft_ctx *ctx,
+				     const struct nft_set *set,
+				     const struct nft_set_elem *elem,
+				     int event, u16 flags)
 {
 	struct net *net = ctx->net;
 	u32 portid = ctx->portid;
@@ -3515,9 +3500,8 @@ static int nf_tables_setelem_notify(const struct nft_ctx *ctx,
 	int err;
 
 	if (!ctx->report && !nfnetlink_has_listeners(net, NFNLGRP_NFTABLES))
-		return 0;
+		return;
 
-	err = -ENOBUFS;
 	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (skb == NULL)
 		goto err;
@@ -3529,12 +3513,11 @@ static int nf_tables_setelem_notify(const struct nft_ctx *ctx,
 		goto err;
 	}
 
-	err = nfnetlink_send(skb, net, portid, NFNLGRP_NFTABLES, ctx->report,
-			     GFP_KERNEL);
+	nfnetlink_send(skb, net, portid, NFNLGRP_NFTABLES, ctx->report,
+		       GFP_KERNEL);
+	return;
 err:
-	if (err < 0)
-		nfnetlink_set_err(net, portid, NFNLGRP_NFTABLES, err);
-	return err;
+	nfnetlink_set_err(net, portid, NFNLGRP_NFTABLES, -ENOBUFS);
 }
 
 static struct nft_trans *nft_trans_elem_alloc(struct nft_ctx *ctx,
@@ -4476,18 +4459,17 @@ static int nf_tables_delobj(struct net *net, struct sock *nlsk,
 	return nft_delobj(&ctx, obj);
 }
 
-int nft_obj_notify(struct net *net, struct nft_table *table,
-		   struct nft_object *obj, u32 portid, u32 seq, int event,
-		   int family, int report, gfp_t gfp)
+void nft_obj_notify(struct net *net, struct nft_table *table,
+		    struct nft_object *obj, u32 portid, u32 seq, int event,
+		    int family, int report, gfp_t gfp)
 {
 	struct sk_buff *skb;
 	int err;
 
 	if (!report &&
 	    !nfnetlink_has_listeners(net, NFNLGRP_NFTABLES))
-		return 0;
+		return;
 
-	err = -ENOBUFS;
 	skb = nlmsg_new(NLMSG_GOODSIZE, gfp);
 	if (skb == NULL)
 		goto err;
@@ -4499,21 +4481,18 @@ int nft_obj_notify(struct net *net, struct nft_table *table,
 		goto err;
 	}
 
-	err = nfnetlink_send(skb, net, portid, NFNLGRP_NFTABLES, report, gfp);
+	nfnetlink_send(skb, net, portid, NFNLGRP_NFTABLES, report, gfp);
+	return;
 err:
-	if (err < 0) {
-		nfnetlink_set_err(net, portid, NFNLGRP_NFTABLES, err);
-	}
-	return err;
+	nfnetlink_set_err(net, portid, NFNLGRP_NFTABLES, -ENOBUFS);
 }
 EXPORT_SYMBOL_GPL(nft_obj_notify);
 
-static int nf_tables_obj_notify(const struct nft_ctx *ctx,
-				struct nft_object *obj, int event)
+static void nf_tables_obj_notify(const struct nft_ctx *ctx,
+				 struct nft_object *obj, int event)
 {
-	return nft_obj_notify(ctx->net, ctx->table, obj, ctx->portid,
-			      ctx->seq, event, ctx->afi->family, ctx->report,
-			      GFP_KERNEL);
+	nft_obj_notify(ctx->net, ctx->table, obj, ctx->portid, ctx->seq, event,
+		       ctx->afi->family, ctx->report, GFP_KERNEL);
 }
 
 static int nf_tables_fill_gen_info(struct sk_buff *skb, struct net *net,
@@ -4543,7 +4522,8 @@ static int nf_tables_fill_gen_info(struct sk_buff *skb, struct net *net,
 	return -EMSGSIZE;
 }
 
-static int nf_tables_gen_notify(struct net *net, struct sk_buff *skb, int event)
+static void nf_tables_gen_notify(struct net *net, struct sk_buff *skb,
+				 int event)
 {
 	struct nlmsghdr *nlh = nlmsg_hdr(skb);
 	struct sk_buff *skb2;
@@ -4551,9 +4531,8 @@ static int nf_tables_gen_notify(struct net *net, struct sk_buff *skb, int event)
 
 	if (nlmsg_report(nlh) &&
 	    !nfnetlink_has_listeners(net, NFNLGRP_NFTABLES))
-		return 0;
+		return;
 
-	err = -ENOBUFS;
 	skb2 = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (skb2 == NULL)
 		goto err;
@@ -4565,14 +4544,12 @@ static int nf_tables_gen_notify(struct net *net, struct sk_buff *skb, int event)
 		goto err;
 	}
 
-	err = nfnetlink_send(skb2, net, NETLINK_CB(skb).portid,
-			     NFNLGRP_NFTABLES, nlmsg_report(nlh), GFP_KERNEL);
+	nfnetlink_send(skb2, net, NETLINK_CB(skb).portid, NFNLGRP_NFTABLES,
+		       nlmsg_report(nlh), GFP_KERNEL);
+	return;
 err:
-	if (err < 0) {
-		nfnetlink_set_err(net, NETLINK_CB(skb).portid, NFNLGRP_NFTABLES,
-				  err);
-	}
-	return err;
+	nfnetlink_set_err(net, NETLINK_CB(skb).portid, NFNLGRP_NFTABLES,
+			  -ENOBUFS);
 }
 
 static int nf_tables_getgen(struct net *net, struct sock *nlsk,
-- 
2.1.4
