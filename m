From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/15] netfilter: nft_limit: add burst parameter
Date: Wed, 19 Aug 2015 21:18:24 +0200
Message-ID: <1440011911-4359-9-git-send-email-pablo@netfilter.org>
References: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44911 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845AbbHSTMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 15:12:44 -0400
In-Reply-To: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the burst parameter. This burst indicates the number of packets
that can exceed the limit.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |    2 ++
 net/netfilter/nft_limit.c                |   20 ++++++++++++++++++--
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 2ef35f2..cafd789 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -761,11 +761,13 @@ enum nft_ct_attributes {
  *
  * @NFTA_LIMIT_RATE: refill rate (NLA_U64)
  * @NFTA_LIMIT_UNIT: refill unit (NLA_U64)
+ * @NFTA_LIMIT_BURST: burst (NLA_U32)
  */
 enum nft_limit_attributes {
 	NFTA_LIMIT_UNSPEC,
 	NFTA_LIMIT_RATE,
 	NFTA_LIMIT_UNIT,
+	NFTA_LIMIT_BURST,
 	__NFTA_LIMIT_MAX
 };
 #define NFTA_LIMIT_MAX		(__NFTA_LIMIT_MAX - 1)
diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index c4d1b1b..d8c5ff1 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -25,6 +25,7 @@ struct nft_limit {
 	u64		tokens_max;
 	u64		rate;
 	u64		nsecs;
+	u32		burst;
 };
 
 static inline bool nft_limit_eval(struct nft_limit *limit, u64 cost)
@@ -65,6 +66,18 @@ static int nft_limit_init(struct nft_limit *limit,
 	if (limit->rate == 0 || limit->nsecs < unit)
 		return -EOVERFLOW;
 	limit->tokens = limit->tokens_max = limit->nsecs;
+
+	if (tb[NFTA_LIMIT_BURST]) {
+		u64 rate;
+
+		limit->burst = ntohl(nla_get_be32(tb[NFTA_LIMIT_BURST]));
+
+		rate = limit->rate + limit->burst;
+		if (rate < limit->rate)
+			return -EOVERFLOW;
+
+		limit->rate = rate;
+	}
 	limit->last = ktime_get_ns();
 
 	return 0;
@@ -73,9 +86,11 @@ static int nft_limit_init(struct nft_limit *limit,
 static int nft_limit_dump(struct sk_buff *skb, const struct nft_limit *limit)
 {
 	u64 secs = div_u64(limit->nsecs, NSEC_PER_SEC);
+	u64 rate = limit->rate - limit->burst;
 
-	if (nla_put_be64(skb, NFTA_LIMIT_RATE, cpu_to_be64(limit->rate)) ||
-	    nla_put_be64(skb, NFTA_LIMIT_UNIT, cpu_to_be64(secs)))
+	if (nla_put_be64(skb, NFTA_LIMIT_RATE, cpu_to_be64(rate)) ||
+	    nla_put_be64(skb, NFTA_LIMIT_UNIT, cpu_to_be64(secs)) ||
+	    nla_put_be32(skb, NFTA_LIMIT_BURST, htonl(limit->burst)))
 		goto nla_put_failure;
 	return 0;
 
@@ -96,6 +111,7 @@ static void nft_limit_pkts_eval(const struct nft_expr *expr,
 static const struct nla_policy nft_limit_policy[NFTA_LIMIT_MAX + 1] = {
 	[NFTA_LIMIT_RATE]	= { .type = NLA_U64 },
 	[NFTA_LIMIT_UNIT]	= { .type = NLA_U64 },
+	[NFTA_LIMIT_BURST]	= { .type = NLA_U32 },
 };
 
 static int nft_limit_pkts_init(const struct nft_ctx *ctx,
-- 
1.7.10.4
