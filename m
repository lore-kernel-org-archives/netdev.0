From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/6] netfilter: nft_quota: reset quota after dump
Date: Thu,  5 Jan 2017 12:19:48 +0100
Message-ID: <1483615193-2931-2-git-send-email-pablo@netfilter.org>
References: <1483615193-2931-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49642 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754071AbdAELUH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 06:20:07 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 1DA3B52307
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:20:03 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 105C89EBB9
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:20:03 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DBF7147E
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:20:00 +0100 (CET)
In-Reply-To: <1483615193-2931-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dumping of netlink attributes may fail due to insufficient room in the
skbuff, so let's reset consumed quota if we succeed to put netlink
attributes into the skbuff.

Fixes: 43da04a593d8 ("netfilter: nf_tables: atomic dump and reset for stateful objects")
Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_quota.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/nft_quota.c b/net/netfilter/nft_quota.c
index bd6efc53f26d..2d6fe3559912 100644
--- a/net/netfilter/nft_quota.c
+++ b/net/netfilter/nft_quota.c
@@ -110,30 +110,32 @@ static int nft_quota_obj_init(const struct nlattr * const tb[],
 static int nft_quota_do_dump(struct sk_buff *skb, struct nft_quota *priv,
 			     bool reset)
 {
+	u64 consumed, consumed_cap;
 	u32 flags = priv->flags;
-	u64 consumed;
-
-	if (reset) {
-		consumed = atomic64_xchg(&priv->consumed, 0);
-		if (test_and_clear_bit(NFT_QUOTA_DEPLETED_BIT, &priv->flags))
-			flags |= NFT_QUOTA_F_DEPLETED;
-	} else {
-		consumed = atomic64_read(&priv->consumed);
-	}
 
 	/* Since we inconditionally increment consumed quota for each packet
 	 * that we see, don't go over the quota boundary in what we send to
 	 * userspace.
 	 */
-	if (consumed > priv->quota)
-		consumed = priv->quota;
+	consumed = atomic64_read(&priv->consumed);
+	if (consumed >= priv->quota) {
+		consumed_cap = priv->quota;
+		flags |= NFT_QUOTA_F_DEPLETED;
+	} else {
+		consumed_cap = consumed;
+	}
 
 	if (nla_put_be64(skb, NFTA_QUOTA_BYTES, cpu_to_be64(priv->quota),
 			 NFTA_QUOTA_PAD) ||
-	    nla_put_be64(skb, NFTA_QUOTA_CONSUMED, cpu_to_be64(consumed),
+	    nla_put_be64(skb, NFTA_QUOTA_CONSUMED, cpu_to_be64(consumed_cap),
 			 NFTA_QUOTA_PAD) ||
 	    nla_put_be32(skb, NFTA_QUOTA_FLAGS, htonl(flags)))
 		goto nla_put_failure;
+
+	if (reset) {
+		atomic64_sub(consumed, &priv->consumed);
+		clear_bit(NFT_QUOTA_DEPLETED_BIT, &priv->flags);
+	}
 	return 0;
 
 nla_put_failure:
-- 
2.1.4
