From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 10/14] ipv4: Use 32-bit loads for ID and length in GRO
Date: Wed, 27 May 2009 14:50:29 +1000
Message-ID: <E1M9B5x-0001Sw-RR@gondolin.me.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45734 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759879AbZE0FTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 01:19:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv4: Use 32-bit loads for ID and length in GRO

This patch optimises the IPv4 GRO code by using 32-bit loads
(instead of 16-bit ones) on the ID and length checks in the receive
function.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/af_inet.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 644cc55..5abee4c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1248,9 +1248,9 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	struct iphdr *iph;
 	unsigned int hlen;
 	unsigned int off;
+	unsigned int id;
 	int flush = 1;
 	int proto;
-	int id;
 
 	off = skb_gro_offset(skb);
 	hlen = off + sizeof(*iph);
@@ -1274,9 +1274,9 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
 		goto out_unlock;
 
-	flush = ntohs(iph->tot_len) != skb_gro_len(skb) ||
-		iph->frag_off != htons(IP_DF);
-	id = ntohs(iph->id);
+	id = ntohl(*(u32 *)&iph->id);
+	flush = (u16)((ntohl(*(u32 *)iph) ^ skb_gro_len(skb)) | (id ^ IP_DF));
+	id >>= 16;
 
 	for (p = *head; p; p = p->next) {
 		struct iphdr *iph2;
