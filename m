From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/14] netfilter: nft_dup: do not use sreg_dev if the user doesn't specify it
Date: Thu, 10 Nov 2016 01:23:42 +0100
Message-ID: <1478737427-1574-10-git-send-email-pablo@netfilter.org>
References: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37760 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754760AbcKJAYI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 19:24:08 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 915B39662D
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7F3A9DA853
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8ACF1DA814
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:24:05 +0100 (CET)
In-Reply-To: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

The NFTA_DUP_SREG_DEV attribute is not a must option, so we should use it
in routing lookup only when the user specify it.

Fixes: d877f07112f1 ("netfilter: nf_tables: add nft_dup expression")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nft_dup_ipv4.c | 6 ++++--
 net/ipv6/netfilter/nft_dup_ipv6.c | 6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/nft_dup_ipv4.c b/net/ipv4/netfilter/nft_dup_ipv4.c
index bf855e64fc45..0c01a270bf9f 100644
--- a/net/ipv4/netfilter/nft_dup_ipv4.c
+++ b/net/ipv4/netfilter/nft_dup_ipv4.c
@@ -28,7 +28,7 @@ static void nft_dup_ipv4_eval(const struct nft_expr *expr,
 	struct in_addr gw = {
 		.s_addr = (__force __be32)regs->data[priv->sreg_addr],
 	};
-	int oif = regs->data[priv->sreg_dev];
+	int oif = priv->sreg_dev ? regs->data[priv->sreg_dev] : -1;
 
 	nf_dup_ipv4(pkt->net, pkt->skb, pkt->hook, &gw, oif);
 }
@@ -59,7 +59,9 @@ static int nft_dup_ipv4_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	struct nft_dup_ipv4 *priv = nft_expr_priv(expr);
 
-	if (nft_dump_register(skb, NFTA_DUP_SREG_ADDR, priv->sreg_addr) ||
+	if (nft_dump_register(skb, NFTA_DUP_SREG_ADDR, priv->sreg_addr))
+		goto nla_put_failure;
+	if (priv->sreg_dev &&
 	    nft_dump_register(skb, NFTA_DUP_SREG_DEV, priv->sreg_dev))
 		goto nla_put_failure;
 
diff --git a/net/ipv6/netfilter/nft_dup_ipv6.c b/net/ipv6/netfilter/nft_dup_ipv6.c
index 8bfd470cbe72..831f86e1ec08 100644
--- a/net/ipv6/netfilter/nft_dup_ipv6.c
+++ b/net/ipv6/netfilter/nft_dup_ipv6.c
@@ -26,7 +26,7 @@ static void nft_dup_ipv6_eval(const struct nft_expr *expr,
 {
 	struct nft_dup_ipv6 *priv = nft_expr_priv(expr);
 	struct in6_addr *gw = (struct in6_addr *)&regs->data[priv->sreg_addr];
-	int oif = regs->data[priv->sreg_dev];
+	int oif = priv->sreg_dev ? regs->data[priv->sreg_dev] : -1;
 
 	nf_dup_ipv6(pkt->net, pkt->skb, pkt->hook, gw, oif);
 }
@@ -57,7 +57,9 @@ static int nft_dup_ipv6_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	struct nft_dup_ipv6 *priv = nft_expr_priv(expr);
 
-	if (nft_dump_register(skb, NFTA_DUP_SREG_ADDR, priv->sreg_addr) ||
+	if (nft_dump_register(skb, NFTA_DUP_SREG_ADDR, priv->sreg_addr))
+		goto nla_put_failure;
+	if (priv->sreg_dev &&
 	    nft_dump_register(skb, NFTA_DUP_SREG_DEV, priv->sreg_dev))
 		goto nla_put_failure;
 
-- 
2.1.4
