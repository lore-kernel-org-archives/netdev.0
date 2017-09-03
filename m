From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/47] netfilter: nf_tables: fib: use skb_header_pointer
Date: Mon,  4 Sep 2017 00:25:47 +0200
Message-ID: <1504477589-12045-6-git-send-email-pablo@netfilter.org>
References: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50808 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753152AbdICW0m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:26:42 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 96917190F6D
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:26:15 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 80F7EB502E
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:26:15 +0200 (CEST)
In-Reply-To: <1504477589-12045-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Pablo M. Bermudo Garay" <pablombg@gmail.com>

This is a preparatory patch for adding fib support to the netdev family.

The netdev family receives the packets from ingress hook. At this point
we have no guarantee that the ip header is linear. So this patch
replaces ip_hdr with skb_header_pointer in order to address that
possible situation.

Signed-off-by: Pablo M. Bermudo Garay <pablombg@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nft_fib_ipv4.c | 20 ++++++++++++++++----
 net/ipv6/netfilter/nft_fib_ipv6.c | 29 +++++++++++++++++++++++------
 2 files changed, 39 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/netfilter/nft_fib_ipv4.c b/net/ipv4/netfilter/nft_fib_ipv4.c
index de3681df2ce7..e50976e3c213 100644
--- a/net/ipv4/netfilter/nft_fib_ipv4.c
+++ b/net/ipv4/netfilter/nft_fib_ipv4.c
@@ -32,9 +32,10 @@ void nft_fib4_eval_type(const struct nft_expr *expr, struct nft_regs *regs,
 			const struct nft_pktinfo *pkt)
 {
 	const struct nft_fib *priv = nft_expr_priv(expr);
+	int noff = skb_network_offset(pkt->skb);
 	u32 *dst = &regs->data[priv->dreg];
 	const struct net_device *dev = NULL;
-	const struct iphdr *iph;
+	struct iphdr *iph, _iph;
 	__be32 addr;
 
 	if (priv->flags & NFTA_FIB_F_IIF)
@@ -42,7 +43,12 @@ void nft_fib4_eval_type(const struct nft_expr *expr, struct nft_regs *regs,
 	else if (priv->flags & NFTA_FIB_F_OIF)
 		dev = nft_out(pkt);
 
-	iph = ip_hdr(pkt->skb);
+	iph = skb_header_pointer(pkt->skb, noff, sizeof(_iph), &_iph);
+	if (!iph) {
+		regs->verdict.code = NFT_BREAK;
+		return;
+	}
+
 	if (priv->flags & NFTA_FIB_F_DADDR)
 		addr = iph->daddr;
 	else
@@ -61,8 +67,9 @@ void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
 		   const struct nft_pktinfo *pkt)
 {
 	const struct nft_fib *priv = nft_expr_priv(expr);
+	int noff = skb_network_offset(pkt->skb);
 	u32 *dest = &regs->data[priv->dreg];
-	const struct iphdr *iph;
+	struct iphdr *iph, _iph;
 	struct fib_result res;
 	struct flowi4 fl4 = {
 		.flowi4_scope = RT_SCOPE_UNIVERSE,
@@ -95,7 +102,12 @@ void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
 		return;
 	}
 
-	iph = ip_hdr(pkt->skb);
+	iph = skb_header_pointer(pkt->skb, noff, sizeof(_iph), &_iph);
+	if (!iph) {
+		regs->verdict.code = NFT_BREAK;
+		return;
+	}
+
 	if (ipv4_is_zeronet(iph->saddr)) {
 		if (ipv4_is_lbcast(iph->daddr) ||
 		    ipv4_is_local_multicast(iph->daddr)) {
diff --git a/net/ipv6/netfilter/nft_fib_ipv6.c b/net/ipv6/netfilter/nft_fib_ipv6.c
index 43f91d9b086c..54b5899543ef 100644
--- a/net/ipv6/netfilter/nft_fib_ipv6.c
+++ b/net/ipv6/netfilter/nft_fib_ipv6.c
@@ -25,9 +25,9 @@ static int get_ifindex(const struct net_device *dev)
 
 static int nft_fib6_flowi_init(struct flowi6 *fl6, const struct nft_fib *priv,
 			       const struct nft_pktinfo *pkt,
-			       const struct net_device *dev)
+			       const struct net_device *dev,
+			       struct ipv6hdr *iph)
 {
-	const struct ipv6hdr *iph = ipv6_hdr(pkt->skb);
 	int lookup_flags = 0;
 
 	if (priv->flags & NFTA_FIB_F_DADDR) {
@@ -55,7 +55,8 @@ static int nft_fib6_flowi_init(struct flowi6 *fl6, const struct nft_fib *priv,
 }
 
 static u32 __nft_fib6_eval_type(const struct nft_fib *priv,
-				const struct nft_pktinfo *pkt)
+				const struct nft_pktinfo *pkt,
+				struct ipv6hdr *iph)
 {
 	const struct net_device *dev = NULL;
 	const struct nf_ipv6_ops *v6ops;
@@ -77,7 +78,7 @@ static u32 __nft_fib6_eval_type(const struct nft_fib *priv,
 	else if (priv->flags & NFTA_FIB_F_OIF)
 		dev = nft_out(pkt);
 
-	nft_fib6_flowi_init(&fl6, priv, pkt, dev);
+	nft_fib6_flowi_init(&fl6, priv, pkt, dev, iph);
 
 	v6ops = nf_get_ipv6_ops();
 	if (dev && v6ops && v6ops->chk_addr(nft_net(pkt), &fl6.daddr, dev, true))
@@ -131,9 +132,17 @@ void nft_fib6_eval_type(const struct nft_expr *expr, struct nft_regs *regs,
 			const struct nft_pktinfo *pkt)
 {
 	const struct nft_fib *priv = nft_expr_priv(expr);
+	int noff = skb_network_offset(pkt->skb);
 	u32 *dest = &regs->data[priv->dreg];
+	struct ipv6hdr *iph, _iph;
 
-	*dest = __nft_fib6_eval_type(priv, pkt);
+	iph = skb_header_pointer(pkt->skb, noff, sizeof(_iph), &_iph);
+	if (!iph) {
+		regs->verdict.code = NFT_BREAK;
+		return;
+	}
+
+	*dest = __nft_fib6_eval_type(priv, pkt, iph);
 }
 EXPORT_SYMBOL_GPL(nft_fib6_eval_type);
 
@@ -141,8 +150,10 @@ void nft_fib6_eval(const struct nft_expr *expr, struct nft_regs *regs,
 		   const struct nft_pktinfo *pkt)
 {
 	const struct nft_fib *priv = nft_expr_priv(expr);
+	int noff = skb_network_offset(pkt->skb);
 	const struct net_device *oif = NULL;
 	u32 *dest = &regs->data[priv->dreg];
+	struct ipv6hdr *iph, _iph;
 	struct flowi6 fl6 = {
 		.flowi6_iif = LOOPBACK_IFINDEX,
 		.flowi6_proto = pkt->tprot,
@@ -155,7 +166,13 @@ void nft_fib6_eval(const struct nft_expr *expr, struct nft_regs *regs,
 	else if (priv->flags & NFTA_FIB_F_OIF)
 		oif = nft_out(pkt);
 
-	lookup_flags = nft_fib6_flowi_init(&fl6, priv, pkt, oif);
+	iph = skb_header_pointer(pkt->skb, noff, sizeof(_iph), &_iph);
+	if (!iph) {
+		regs->verdict.code = NFT_BREAK;
+		return;
+	}
+
+	lookup_flags = nft_fib6_flowi_init(&fl6, priv, pkt, oif, iph);
 
 	if (nft_hook(pkt) == NF_INET_PRE_ROUTING &&
 	    nft_fib_is_loopback(pkt->skb, nft_in(pkt))) {
-- 
2.1.4
