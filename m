From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] gro: should aggregate frames without DF
Date: Fri, 31 May 2013 14:18:10 -0700
Message-ID: <1370035090.5109.113.camel@edumazet-glaptop>
References: <1370019752.5109.108.camel@edumazet-glaptop>
	 <1370030944.2703.17.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:49379 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753886Ab3EaVSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 17:18:13 -0400
Received: by mail-ob0-f180.google.com with SMTP id eh20so4003377obb.11
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 14:18:12 -0700 (PDT)
In-Reply-To: <1370030944.2703.17.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

GRO on IPv4 doesn't aggregate frames if they don't have DF bit set.

Some servers use IP_MTU_DISCOVER/IP_PMTUDISC_PROBE, so linux receivers
are unable to aggregate this kind of traffic.

The right thing to do is to allow aggregation as long as the DF bit has
same value on all segments.

bnx2x LRO does this correctly.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jerry Chu <hkchu@google.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Ben Hutchings <bhutchings@solarflare.com>
---
v2 : fix from Ben Hutchings (Thanks !)

 net/ipv4/af_inet.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index b05ae96..9c090c7 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1385,7 +1385,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 		goto out_unlock;
 
 	id = ntohl(*(__be32 *)&iph->id);
-	flush = (u16)((ntohl(*(__be32 *)iph) ^ skb_gro_len(skb)) | (id ^ IP_DF));
+	flush = (u16)((ntohl(*(__be32 *)iph) ^ skb_gro_len(skb)) | (id & ~IP_DF));
 	id >>= 16;
 
 	for (p = *head; p; p = p->next) {
@@ -1407,6 +1407,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 		NAPI_GRO_CB(p)->flush |=
 			(iph->ttl ^ iph2->ttl) |
 			(iph->tos ^ iph2->tos) |
+			((iph->frag_off ^ iph2->frag_off) & htons(IP_DF)) |
 			((u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) ^ id);
 
 		NAPI_GRO_CB(p)->flush |= flush;
