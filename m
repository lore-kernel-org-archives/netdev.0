From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/17] netfilter: nft_limit: allow to invert matching criteria
Date: Fri,  8 Jan 2016 15:02:06 +0100
Message-ID: <1452261737-7475-7-git-send-email-pablo@netfilter.org>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54084 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755155AbcAHODM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 09:03:12 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id E2549DA888
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:10 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id D2A95DA86E
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:10 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 7D76E4C348
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:05 +0100 (CET)
In-Reply-To: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows you to invert the ratelimit matching criteria, so you
can match packets over the ratelimit. This is required to support what
hashlimit does.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  6 ++++++
 net/netfilter/nft_limit.c                | 16 +++++++++++++---
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index b48a3ab..22043ce 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -780,6 +780,10 @@ enum nft_limit_type {
 	NFT_LIMIT_PKT_BYTES
 };
 
+enum nft_limit_flags {
+	NFT_LIMIT_F_INV	= (1 << 0),
+};
+
 /**
  * enum nft_limit_attributes - nf_tables limit expression netlink attributes
  *
@@ -787,6 +791,7 @@ enum nft_limit_type {
  * @NFTA_LIMIT_UNIT: refill unit (NLA_U64)
  * @NFTA_LIMIT_BURST: burst (NLA_U32)
  * @NFTA_LIMIT_TYPE: type of limit (NLA_U32: enum nft_limit_type)
+ * @NFTA_LIMIT_FLAGS: flags (NLA_U32: enum nft_limit_flags)
  */
 enum nft_limit_attributes {
 	NFTA_LIMIT_UNSPEC,
@@ -794,6 +799,7 @@ enum nft_limit_attributes {
 	NFTA_LIMIT_UNIT,
 	NFTA_LIMIT_BURST,
 	NFTA_LIMIT_TYPE,
+	NFTA_LIMIT_FLAGS,
 	__NFTA_LIMIT_MAX
 };
 #define NFTA_LIMIT_MAX		(__NFTA_LIMIT_MAX - 1)
diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index 5d67938..99d1857 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -26,6 +26,7 @@ struct nft_limit {
 	u64		rate;
 	u64		nsecs;
 	u32		burst;
+	bool		invert;
 };
 
 static inline bool nft_limit_eval(struct nft_limit *limit, u64 cost)
@@ -44,11 +45,11 @@ static inline bool nft_limit_eval(struct nft_limit *limit, u64 cost)
 	if (delta >= 0) {
 		limit->tokens = delta;
 		spin_unlock_bh(&limit_lock);
-		return false;
+		return limit->invert;
 	}
 	limit->tokens = tokens;
 	spin_unlock_bh(&limit_lock);
-	return true;
+	return !limit->invert;
 }
 
 static int nft_limit_init(struct nft_limit *limit,
@@ -78,6 +79,12 @@ static int nft_limit_init(struct nft_limit *limit,
 
 		limit->rate = rate;
 	}
+	if (tb[NFTA_LIMIT_FLAGS]) {
+		u32 flags = ntohl(nla_get_be32(tb[NFTA_LIMIT_FLAGS]));
+
+		if (flags & NFT_LIMIT_F_INV)
+			limit->invert = true;
+	}
 	limit->last = ktime_get_ns();
 
 	return 0;
@@ -86,13 +93,15 @@ static int nft_limit_init(struct nft_limit *limit,
 static int nft_limit_dump(struct sk_buff *skb, const struct nft_limit *limit,
 			  enum nft_limit_type type)
 {
+	u32 flags = limit->invert ? NFT_LIMIT_F_INV : 0;
 	u64 secs = div_u64(limit->nsecs, NSEC_PER_SEC);
 	u64 rate = limit->rate - limit->burst;
 
 	if (nla_put_be64(skb, NFTA_LIMIT_RATE, cpu_to_be64(rate)) ||
 	    nla_put_be64(skb, NFTA_LIMIT_UNIT, cpu_to_be64(secs)) ||
 	    nla_put_be32(skb, NFTA_LIMIT_BURST, htonl(limit->burst)) ||
-	    nla_put_be32(skb, NFTA_LIMIT_TYPE, htonl(type)))
+	    nla_put_be32(skb, NFTA_LIMIT_TYPE, htonl(type)) ||
+	    nla_put_be32(skb, NFTA_LIMIT_FLAGS, htonl(flags)))
 		goto nla_put_failure;
 	return 0;
 
@@ -120,6 +129,7 @@ static const struct nla_policy nft_limit_policy[NFTA_LIMIT_MAX + 1] = {
 	[NFTA_LIMIT_UNIT]	= { .type = NLA_U64 },
 	[NFTA_LIMIT_BURST]	= { .type = NLA_U32 },
 	[NFTA_LIMIT_TYPE]	= { .type = NLA_U32 },
+	[NFTA_LIMIT_FLAGS]	= { .type = NLA_U32 },
 };
 
 static int nft_limit_pkts_init(const struct nft_ctx *ctx,
-- 
2.1.4
