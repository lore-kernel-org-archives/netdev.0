From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 27/47] netfilter: exthdr: factor out tcp option access
Date: Mon,  4 Sep 2017 00:40:15 +0200
Message-ID: <1504478435-13160-5-git-send-email-pablo@netfilter.org>
References: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52698 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753168AbdICWky (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:40:54 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 97DCE190F67
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:40:27 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7B3BDB5056
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:40:27 +0200 (CEST)
In-Reply-To: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_exthdr.c | 33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index 1ec49fe5845f..921c95f2c583 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -61,6 +61,26 @@ static void nft_exthdr_ipv6_eval(const struct nft_expr *expr,
 	regs->verdict.code = NFT_BREAK;
 }
 
+static void *
+nft_tcp_header_pointer(const struct nft_pktinfo *pkt,
+		       unsigned int len, void *buffer, unsigned int *tcphdr_len)
+{
+	struct tcphdr *tcph;
+
+	if (!pkt->tprot_set || pkt->tprot != IPPROTO_TCP)
+		return NULL;
+
+	tcph = skb_header_pointer(pkt->skb, pkt->xt.thoff, sizeof(*tcph), buffer);
+	if (!tcph)
+		return NULL;
+
+	*tcphdr_len = __tcp_hdrlen(tcph);
+	if (*tcphdr_len < sizeof(*tcph) || *tcphdr_len > len)
+		return NULL;
+
+	return skb_header_pointer(pkt->skb, pkt->xt.thoff, *tcphdr_len, buffer);
+}
+
 static void nft_exthdr_tcp_eval(const struct nft_expr *expr,
 				struct nft_regs *regs,
 				const struct nft_pktinfo *pkt)
@@ -72,18 +92,7 @@ static void nft_exthdr_tcp_eval(const struct nft_expr *expr,
 	struct tcphdr *tcph;
 	u8 *opt;
 
-	if (!pkt->tprot_set || pkt->tprot != IPPROTO_TCP)
-		goto err;
-
-	tcph = skb_header_pointer(pkt->skb, pkt->xt.thoff, sizeof(*tcph), buff);
-	if (!tcph)
-		goto err;
-
-	tcphdr_len = __tcp_hdrlen(tcph);
-	if (tcphdr_len < sizeof(*tcph))
-		goto err;
-
-	tcph = skb_header_pointer(pkt->skb, pkt->xt.thoff, tcphdr_len, buff);
+	tcph = nft_tcp_header_pointer(pkt, sizeof(buff), buff, &tcphdr_len);
 	if (!tcph)
 		goto err;
 
-- 
2.1.4
