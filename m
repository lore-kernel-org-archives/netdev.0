From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: GRO should be ECN friendly
Date: Sat, 06 Oct 2012 08:32:26 +0200
Message-ID: <1349505146.21172.190.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49599 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab2JFGcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2012 02:32:31 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1265471bkc.19
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 23:32:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

IPv4 side of the problem was addressed in commit a9e050f4e7f9d
(net: tcp: GRO should be ECN friendly)

This patch does the same, but for IPv6 : A Traffic Class mismatch
doesnt mean flows are different, but instead should force a flush
of previous packets.

This patch removes artificial packet reordering problem.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/ipv6/af_inet6.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index e22e6d8..7739d28 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -880,22 +880,25 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 	nlen = skb_network_header_len(skb);
 
 	for (p = *head; p; p = p->next) {
-		struct ipv6hdr *iph2;
+		const struct ipv6hdr *iph2;
+		u32 first_word; /* <Version:4><Traffic_Class:8><Flow_Label:20> */
 
 		if (!NAPI_GRO_CB(p)->same_flow)
 			continue;
 
 		iph2 = ipv6_hdr(p);
+		first_word = *(u32 *)iph ^ *(u32 *)iph2 ;
 
-		/* All fields must match except length. */
+		/* All fields must match except length and Traffic Class. */
 		if (nlen != skb_network_header_len(p) ||
-		    memcmp(iph, iph2, offsetof(struct ipv6hdr, payload_len)) ||
+		    (first_word & htonl(0xF00FFFFF)) ||
 		    memcmp(&iph->nexthdr, &iph2->nexthdr,
 			   nlen - offsetof(struct ipv6hdr, nexthdr))) {
 			NAPI_GRO_CB(p)->same_flow = 0;
 			continue;
 		}
-
+		/* flush if Traffic Class fields are different */
+		NAPI_GRO_CB(p)->flush |= (first_word & htonl(0x0FF00000));
 		NAPI_GRO_CB(p)->flush |= flush;
 	}
 
