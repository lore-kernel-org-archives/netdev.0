From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/13] netfilter: nft_dynset: fix element timeout for HZ != 1000
Date: Fri, 21 Oct 2016 12:12:12 +0200
Message-ID: <1477044743-18948-3-git-send-email-pablo@netfilter.org>
References: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36236 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755043AbcJUKNA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 06:13:00 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6897A26E15
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:39 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 54168BAC44
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:39 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C2F20DA841
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:36 +0200 (CEST)
In-Reply-To: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Anders K. Pedersen" <akp@cohaesio.com>

With HZ=100 element timeout in dynamic sets (i.e. flow tables) is 10 times
higher than configured.

Add proper conversion to/from jiffies, when interacting with userspace.

I tested this on Linux 4.8.1, and it applies cleanly to current nf and
nf-next trees.

Fixes: 22fe54d5fefc ("netfilter: nf_tables: add support for dynamic set updates")
Signed-off-by: Anders K. Pedersen <akp@cohaesio.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_dynset.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nft_dynset.c b/net/netfilter/nft_dynset.c
index e3b83c31da2e..517f08767a3c 100644
--- a/net/netfilter/nft_dynset.c
+++ b/net/netfilter/nft_dynset.c
@@ -158,7 +158,8 @@ static int nft_dynset_init(const struct nft_ctx *ctx,
 	if (tb[NFTA_DYNSET_TIMEOUT] != NULL) {
 		if (!(set->flags & NFT_SET_TIMEOUT))
 			return -EINVAL;
-		timeout = be64_to_cpu(nla_get_be64(tb[NFTA_DYNSET_TIMEOUT]));
+		timeout = msecs_to_jiffies(be64_to_cpu(nla_get_be64(
+						tb[NFTA_DYNSET_TIMEOUT])));
 	}
 
 	priv->sreg_key = nft_parse_register(tb[NFTA_DYNSET_SREG_KEY]);
@@ -246,7 +247,8 @@ static int nft_dynset_dump(struct sk_buff *skb, const struct nft_expr *expr)
 		goto nla_put_failure;
 	if (nla_put_string(skb, NFTA_DYNSET_SET_NAME, priv->set->name))
 		goto nla_put_failure;
-	if (nla_put_be64(skb, NFTA_DYNSET_TIMEOUT, cpu_to_be64(priv->timeout),
+	if (nla_put_be64(skb, NFTA_DYNSET_TIMEOUT,
+			 cpu_to_be64(jiffies_to_msecs(priv->timeout)),
 			 NFTA_DYNSET_PAD))
 		goto nla_put_failure;
 	if (priv->expr && nft_expr_dump(skb, NFTA_DYNSET_EXPR, priv->expr))
-- 
2.1.4
