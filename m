From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/6] netfilter: nft_payload: mangle ckecksum if NFT_PAYLOAD_L4CSUM_PSEUDOHDR is set
Date: Thu,  5 Jan 2017 12:19:51 +0100
Message-ID: <1483615193-2931-5-git-send-email-pablo@netfilter.org>
References: <1483615193-2931-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49682 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761872AbdAELUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 06:20:09 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 9AF2352301
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:20:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8BCEEA7EE6
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:20:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6824DA8257
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:20:04 +0100 (CET)
In-Reply-To: <1483615193-2931-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the NFT_PAYLOAD_L4CSUM_PSEUDOHDR flag is set, then mangle layer 4
checksum. This should not depend on csum_type NFT_PAYLOAD_CSUM_INET
since IPv6 header has no checksum field, but still an update of any of
the pseudoheader fields may trigger a layer 4 checksum update.

Fixes: 1814096980bb ("netfilter: nft_payload: layer 4 checksum adjustment for pseudoheader fields")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_payload.c | 27 +++++++++++++++++++--------
 1 file changed, 19 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 36d2b1096546..7d699bbd45b0 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -250,6 +250,22 @@ static int nft_payload_l4csum_update(const struct nft_pktinfo *pkt,
 	return 0;
 }
 
+static int nft_payload_csum_inet(struct sk_buff *skb, const u32 *src,
+				 __wsum fsum, __wsum tsum, int csum_offset)
+{
+	__sum16 sum;
+
+	if (skb_copy_bits(skb, csum_offset, &sum, sizeof(sum)) < 0)
+		return -1;
+
+	nft_csum_replace(&sum, fsum, tsum);
+	if (!skb_make_writable(skb, csum_offset + sizeof(sum)) ||
+	    skb_store_bits(skb, csum_offset, &sum, sizeof(sum)) < 0)
+		return -1;
+
+	return 0;
+}
+
 static void nft_payload_set_eval(const struct nft_expr *expr,
 				 struct nft_regs *regs,
 				 const struct nft_pktinfo *pkt)
@@ -259,7 +275,6 @@ static void nft_payload_set_eval(const struct nft_expr *expr,
 	const u32 *src = &regs->data[priv->sreg];
 	int offset, csum_offset;
 	__wsum fsum, tsum;
-	__sum16 sum;
 
 	switch (priv->base) {
 	case NFT_PAYLOAD_LL_HEADER:
@@ -282,18 +297,14 @@ static void nft_payload_set_eval(const struct nft_expr *expr,
 	csum_offset = offset + priv->csum_offset;
 	offset += priv->offset;
 
-	if (priv->csum_type == NFT_PAYLOAD_CSUM_INET &&
+	if ((priv->csum_type == NFT_PAYLOAD_CSUM_INET || priv->csum_flags) &&
 	    (priv->base != NFT_PAYLOAD_TRANSPORT_HEADER ||
 	     skb->ip_summed != CHECKSUM_PARTIAL)) {
-		if (skb_copy_bits(skb, csum_offset, &sum, sizeof(sum)) < 0)
-			goto err;
-
 		fsum = skb_checksum(skb, offset, priv->len, 0);
 		tsum = csum_partial(src, priv->len, 0);
-		nft_csum_replace(&sum, fsum, tsum);
 
-		if (!skb_make_writable(skb, csum_offset + sizeof(sum)) ||
-		    skb_store_bits(skb, csum_offset, &sum, sizeof(sum)) < 0)
+		if (priv->csum_type == NFT_PAYLOAD_CSUM_INET &&
+		    nft_payload_csum_inet(skb, src, fsum, tsum, csum_offset))
 			goto err;
 
 		if (priv->csum_flags &&
-- 
2.1.4
