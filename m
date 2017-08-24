From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/5] netfilter: nf_tables: Fix nft limit burst handling
Date: Thu, 24 Aug 2017 16:43:31 +0200
Message-ID: <1503585811-13447-6-git-send-email-pablo@netfilter.org>
References: <1503585811-13447-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50414 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752370AbdHXOnt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 10:43:49 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id CAF331BFA8A
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 16:43:31 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B9948DA4C8
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 16:43:31 +0200 (CEST)
In-Reply-To: <1503585811-13447-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: andy zhou <azhou@ovn.org>

Current implementation treats the burst configuration the same as
rate configuration. This can cause the per packet cost to be lower
than configured. In effect, this bug causes the token bucket to be
refilled at a higher rate than what user has specified.

This patch changes the implementation so that the token bucket size
is controlled by "rate + burst", while maintain the token bucket
refill rate the same as user specified.

Fixes: 96518518cc41 ("netfilter: add nftables")
Signed-off-by: Andy Zhou <azhou@ovn.org>
Acked-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_limit.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/nft_limit.c b/net/netfilter/nft_limit.c
index 18dd57a52651..14538b1d4d11 100644
--- a/net/netfilter/nft_limit.c
+++ b/net/netfilter/nft_limit.c
@@ -65,19 +65,23 @@ static int nft_limit_init(struct nft_limit *limit,
 	limit->nsecs = unit * NSEC_PER_SEC;
 	if (limit->rate == 0 || limit->nsecs < unit)
 		return -EOVERFLOW;
-	limit->tokens = limit->tokens_max = limit->nsecs;
-
-	if (tb[NFTA_LIMIT_BURST]) {
-		u64 rate;
 
+	if (tb[NFTA_LIMIT_BURST])
 		limit->burst = ntohl(nla_get_be32(tb[NFTA_LIMIT_BURST]));
+	else
+		limit->burst = 0;
+
+	if (limit->rate + limit->burst < limit->rate)
+		return -EOVERFLOW;
 
-		rate = limit->rate + limit->burst;
-		if (rate < limit->rate)
-			return -EOVERFLOW;
+	/* The token bucket size limits the number of tokens can be
+	 * accumulated. tokens_max specifies the bucket size.
+	 * tokens_max = unit * (rate + burst) / rate.
+	 */
+	limit->tokens = div_u64(limit->nsecs * (limit->rate + limit->burst),
+				limit->rate);
+	limit->tokens_max = limit->tokens;
 
-		limit->rate = rate;
-	}
 	if (tb[NFTA_LIMIT_FLAGS]) {
 		u32 flags = ntohl(nla_get_be32(tb[NFTA_LIMIT_FLAGS]));
 
@@ -95,9 +99,8 @@ static int nft_limit_dump(struct sk_buff *skb, const struct nft_limit *limit,
 {
 	u32 flags = limit->invert ? NFT_LIMIT_F_INV : 0;
 	u64 secs = div_u64(limit->nsecs, NSEC_PER_SEC);
-	u64 rate = limit->rate - limit->burst;
 
-	if (nla_put_be64(skb, NFTA_LIMIT_RATE, cpu_to_be64(rate),
+	if (nla_put_be64(skb, NFTA_LIMIT_RATE, cpu_to_be64(limit->rate),
 			 NFTA_LIMIT_PAD) ||
 	    nla_put_be64(skb, NFTA_LIMIT_UNIT, cpu_to_be64(secs),
 			 NFTA_LIMIT_PAD) ||
-- 
2.1.4
