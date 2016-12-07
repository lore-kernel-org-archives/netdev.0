From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 39/50] netfilter: nft_quota: add depleted flag for objects
Date: Wed,  7 Dec 2016 22:52:45 +0100
Message-ID: <1481147576-5690-40-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60234 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933432AbcLGVxx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:53 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id ECF296DA9A
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:51 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DE2EBDA863
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:51 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id AF79CDA860
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:49 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Notify on depleted quota objects. The NFT_QUOTA_F_DEPLETED flag
indicates we have reached overquota.

Add pointer to table from nft_object, so we can use it when sending the
depletion notification to userspace.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |  2 ++
 include/uapi/linux/netfilter/nf_tables.h |  1 +
 net/netfilter/nf_tables_api.c            |  1 +
 net/netfilter/nft_quota.c                | 36 +++++++++++++++++++++++++-------
 4 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 339e374c28b5..ce6fb6e83b32 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -940,6 +940,7 @@ int nft_verdict_dump(struct sk_buff *skb, int type,
  *	struct nft_object - nf_tables stateful object
  *
  *	@list: table stateful object list node
+ *	@table: table this object belongs to
  *	@type: pointer to object type
  *	@data: pointer to object data
  *	@name: name of this stateful object
@@ -950,6 +951,7 @@ int nft_verdict_dump(struct sk_buff *skb, int type,
 struct nft_object {
 	struct list_head		list;
 	char				name[NFT_OBJ_MAXNAMELEN];
+	struct nft_table		*table;
 	u32				genmask:2,
 					use:30;
 	/* runtime data below here */
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 399eac1eee91..4864caca1e8e 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -983,6 +983,7 @@ enum nft_queue_attributes {
 
 enum nft_quota_flags {
 	NFT_QUOTA_F_INV		= (1 << 0),
+	NFT_QUOTA_F_DEPLETED	= (1 << 1),
 };
 
 /**
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 9d2ed3f520ef..c5419701ca79 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4075,6 +4075,7 @@ static int nf_tables_newobj(struct net *net, struct sock *nlsk,
 		err = PTR_ERR(obj);
 		goto err1;
 	}
+	obj->table = table;
 	nla_strlcpy(obj->name, nla[NFTA_OBJ_NAME], NFT_OBJ_MAXNAMELEN);
 
 	err = nft_trans_obj_add(&ctx, NFT_MSG_NEWOBJ, obj);
diff --git a/net/netfilter/nft_quota.c b/net/netfilter/nft_quota.c
index 5d25f57497cb..7f27ebdce7ab 100644
--- a/net/netfilter/nft_quota.c
+++ b/net/netfilter/nft_quota.c
@@ -17,7 +17,7 @@
 
 struct nft_quota {
 	u64		quota;
-	bool		invert;
+	unsigned long	flags;
 	atomic64_t	consumed;
 };
 
@@ -27,11 +27,16 @@ static inline bool nft_overquota(struct nft_quota *priv,
 	return atomic64_add_return(skb->len, &priv->consumed) >= priv->quota;
 }
 
+static inline bool nft_quota_invert(struct nft_quota *priv)
+{
+	return priv->flags & NFT_QUOTA_F_INV;
+}
+
 static inline void nft_quota_do_eval(struct nft_quota *priv,
 				     struct nft_regs *regs,
 				     const struct nft_pktinfo *pkt)
 {
-	if (nft_overquota(priv, pkt->skb) ^ priv->invert)
+	if (nft_overquota(priv, pkt->skb) ^ nft_quota_invert(priv))
 		regs->verdict.code = NFT_BREAK;
 }
 
@@ -40,19 +45,29 @@ static const struct nla_policy nft_quota_policy[NFTA_QUOTA_MAX + 1] = {
 	[NFTA_QUOTA_FLAGS]	= { .type = NLA_U32 },
 };
 
+#define NFT_QUOTA_DEPLETED_BIT	1	/* From NFT_QUOTA_F_DEPLETED. */
+
 static void nft_quota_obj_eval(struct nft_object *obj,
 			       struct nft_regs *regs,
 			       const struct nft_pktinfo *pkt)
 {
 	struct nft_quota *priv = nft_obj_data(obj);
+	bool overquota;
 
-	nft_quota_do_eval(priv, regs, pkt);
+	overquota = nft_overquota(priv, pkt->skb);
+	if (overquota ^ nft_quota_invert(priv))
+		regs->verdict.code = NFT_BREAK;
+
+	if (overquota &&
+	    !test_and_set_bit(NFT_QUOTA_DEPLETED_BIT, &priv->flags))
+		nft_obj_notify(nft_net(pkt), obj->table, obj, 0, 0,
+			       NFT_MSG_NEWOBJ, nft_pf(pkt), 0, GFP_ATOMIC);
 }
 
 static int nft_quota_do_init(const struct nlattr * const tb[],
 			     struct nft_quota *priv)
 {
-	u32 flags = 0;
+	unsigned long flags = 0;
 	u64 quota;
 
 	if (!tb[NFTA_QUOTA_BYTES])
@@ -66,10 +81,12 @@ static int nft_quota_do_init(const struct nlattr * const tb[],
 		flags = ntohl(nla_get_be32(tb[NFTA_QUOTA_FLAGS]));
 		if (flags & ~NFT_QUOTA_F_INV)
 			return -EINVAL;
+		if (flags & NFT_QUOTA_F_DEPLETED)
+			return -EOPNOTSUPP;
 	}
 
 	priv->quota = quota;
-	priv->invert = (flags & NFT_QUOTA_F_INV) ? true : false;
+	priv->flags = flags;
 	atomic64_set(&priv->consumed, 0);
 
 	return 0;
@@ -86,13 +103,16 @@ static int nft_quota_obj_init(const struct nlattr * const tb[],
 static int nft_quota_do_dump(struct sk_buff *skb, struct nft_quota *priv,
 			     bool reset)
 {
-	u32 flags = priv->invert ? NFT_QUOTA_F_INV : 0;
+	u32 flags = priv->flags;
 	u64 consumed;
 
-	if (reset)
+	if (reset) {
 		consumed = atomic64_xchg(&priv->consumed, 0);
-	else
+		if (test_and_clear_bit(NFT_QUOTA_DEPLETED_BIT, &priv->flags))
+			flags |= NFT_QUOTA_F_DEPLETED;
+	} else {
 		consumed = atomic64_read(&priv->consumed);
+	}
 
 	/* Since we inconditionally increment consumed quota for each packet
 	 * that we see, don't go over the quota boundary in what we send to
-- 
2.1.4
