From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 36/50] netfilter: nft_quota: dump consumed quota
Date: Wed,  7 Dec 2016 22:52:42 +0100
Message-ID: <1481147576-5690-37-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60254 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933418AbcLGVxv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:51 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 42C038CD97
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:49 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3342BDA86E
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:49 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 20FD9DA860
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:47 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new attribute NFTA_QUOTA_CONSUMED that displays the amount of
quota that has been already consumed. This allows us to restore the
internal state of the quota object between reboots as well as to monitor
how wasted it is.

This patch changes the logic to account for the consumed bytes, instead
of the bytes that remain to be consumed.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  2 ++
 net/netfilter/nft_quota.c                | 21 ++++++++++++++++-----
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 1043ce4250c5..3d47582caa80 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -988,12 +988,14 @@ enum nft_quota_flags {
  *
  * @NFTA_QUOTA_BYTES: quota in bytes (NLA_U16)
  * @NFTA_QUOTA_FLAGS: flags (NLA_U32)
+ * @NFTA_QUOTA_CONSUMED: quota already consumed in bytes (NLA_U64)
  */
 enum nft_quota_attributes {
 	NFTA_QUOTA_UNSPEC,
 	NFTA_QUOTA_BYTES,
 	NFTA_QUOTA_FLAGS,
 	NFTA_QUOTA_PAD,
+	NFTA_QUOTA_CONSUMED,
 	__NFTA_QUOTA_MAX
 };
 #define NFTA_QUOTA_MAX		(__NFTA_QUOTA_MAX - 1)
diff --git a/net/netfilter/nft_quota.c b/net/netfilter/nft_quota.c
index 09ce72b1d6bf..0d344209803a 100644
--- a/net/netfilter/nft_quota.c
+++ b/net/netfilter/nft_quota.c
@@ -18,20 +18,20 @@
 struct nft_quota {
 	u64		quota;
 	bool		invert;
-	atomic64_t	remain;
+	atomic64_t	consumed;
 };
 
 static inline bool nft_overquota(struct nft_quota *priv,
-				 const struct nft_pktinfo *pkt)
+				 const struct sk_buff *skb)
 {
-	return atomic64_sub_return(pkt->skb->len, &priv->remain) < 0;
+	return atomic64_add_return(skb->len, &priv->consumed) >= priv->quota;
 }
 
 static inline void nft_quota_do_eval(struct nft_quota *priv,
 				     struct nft_regs *regs,
 				     const struct nft_pktinfo *pkt)
 {
-	if (nft_overquota(priv, pkt) ^ priv->invert)
+	if (nft_overquota(priv, pkt->skb) ^ priv->invert)
 		regs->verdict.code = NFT_BREAK;
 }
 
@@ -70,7 +70,7 @@ static int nft_quota_do_init(const struct nlattr * const tb[],
 
 	priv->quota = quota;
 	priv->invert = (flags & NFT_QUOTA_F_INV) ? true : false;
-	atomic64_set(&priv->remain, quota);
+	atomic64_set(&priv->consumed, 0);
 
 	return 0;
 }
@@ -86,9 +86,20 @@ static int nft_quota_obj_init(const struct nlattr * const tb[],
 static int nft_quota_do_dump(struct sk_buff *skb, const struct nft_quota *priv)
 {
 	u32 flags = priv->invert ? NFT_QUOTA_F_INV : 0;
+	u64 consumed;
+
+	consumed = atomic64_read(&priv->consumed);
+	/* Since we inconditionally increment consumed quota for each packet
+	 * that we see, don't go over the quota boundary in what we send to
+	 * userspace.
+	 */
+	if (consumed > priv->quota)
+		consumed = priv->quota;
 
 	if (nla_put_be64(skb, NFTA_QUOTA_BYTES, cpu_to_be64(priv->quota),
 			 NFTA_QUOTA_PAD) ||
+	    nla_put_be64(skb, NFTA_QUOTA_CONSUMED, cpu_to_be64(consumed),
+			 NFTA_QUOTA_PAD) ||
 	    nla_put_be32(skb, NFTA_QUOTA_FLAGS, htonl(flags)))
 		goto nla_put_failure;
 	return 0;
-- 
2.1.4
