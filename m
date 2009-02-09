From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/4] gro: Optimise IPv4 packet reception
Date: Mon, 09 Feb 2009 15:00:39 +1100
Message-ID: <E1LWNK3-0000nr-26@gondolin.me.apana.org.au>
References: <20090209035930.GA2988@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34970 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753864AbZBIEAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2009 23:00:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Optimise IPv4 packet reception

As this function can be called more than half a million times for
10GbE, it's important to optimise it as much as we can.

This patch does some obvious changes to use 2-byte and 4-byte
operations instead of byte-oriented ones where possible.  Bit
ops are also used to replace logical ops to reduce branching.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/af_inet.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c790877..627be4d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1263,7 +1263,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	if (!ops || !ops->gro_receive)
 		goto out_unlock;
 
-	if (iph->version != 4 || iph->ihl != 5)
+	if (*(u8 *)iph != 0x45)
 		goto out_unlock;
 
 	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
@@ -1281,17 +1281,18 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 
 		iph2 = ip_hdr(p);
 
-		if (iph->protocol != iph2->protocol ||
-		    iph->tos != iph2->tos ||
-		    memcmp(&iph->saddr, &iph2->saddr, 8)) {
+		if ((iph->protocol ^ iph2->protocol) |
+		    (iph->tos ^ iph2->tos) |
+		    (iph->saddr ^ iph2->saddr) |
+		    (iph->daddr ^ iph2->daddr)) {
 			NAPI_GRO_CB(p)->same_flow = 0;
 			continue;
 		}
 
 		/* All fields must match except length and checksum. */
 		NAPI_GRO_CB(p)->flush |=
-			memcmp(&iph->frag_off, &iph2->frag_off, 4) ||
-			(u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) != id;
+			(iph->ttl ^ iph2->ttl) |
+			((u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) ^ id);
 
 		NAPI_GRO_CB(p)->flush |= flush;
 	}
