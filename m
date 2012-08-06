From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH RFC] net: tcp: GRO should be ECN friendly
Date: Mon, 06 Aug 2012 10:34:50 +0200
Message-ID: <1344242090.9299.1656.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57576 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804Ab2HFIe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 04:34:56 -0400
Received: by bkwj10 with SMTP id j10so917681bkw.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 01:34:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While doing TCP ECN tests, I discovered GRO was reordering packets if it
receives one packet with CE set, while previous packets in same NAPI run
have ECT(0) for the same flow :

09:25:25.857620 IP (tos 0x2,ECT(0), ttl 64, id 27893, offset 0, flags
[DF], proto TCP (6), length 4396)
    172.30.42.19.54550 > 172.30.42.13.44139: Flags [.], seq
233801:238145, ack 1, win 115, options [nop,nop,TS val 3397779 ecr
1990627], length 4344

09:25:25.857626 IP (tos 0x3,CE, ttl 64, id 27892, offset 0, flags [DF],
proto TCP (6), length 1500)
    172.30.42.19.54550 > 172.30.42.13.44139: Flags [.], seq
232353:233801, ack 1, win 115, options [nop,nop,TS val 3397779 ecr
1990627], length 1448

09:25:25.857638 IP (tos 0x0, ttl 64, id 34581, offset 0, flags [DF],
proto TCP (6), length 64)
    172.30.42.13.44139 > 172.30.42.19.54550: Flags [.], cksum 0xac8f
(incorrect -> 0xca69), ack 232353, win 1271, options [nop,nop,TS val
1990627 ecr 3397779,nop,nop,sack 1 {233801:238145}], length 0

We have two problems here :

1) GRO reorders packets

  If NIC gave packet1, then packet2, which happen to be from "different
flows"  GRO feeds stack with packet2, then packet1. I have yet to
understand how to solve this problem.

2) GRO is not ECN friendly

Delivering packets out of order makes TCP stack not as fast as it could
be.

In this patch I suggest we make the tos test not part of the 'same_flow'
determination, but part of the 'should flush' logic

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/ipv4/af_inet.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index fe4582c..6681ccf 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1364,7 +1364,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	if (*(u8 *)iph != 0x45)
 		goto out_unlock;
 
-	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
+	if (unlikely(ip_fast_csum((u8 *)iph, 5)))
 		goto out_unlock;
 
 	id = ntohl(*(__be32 *)&iph->id);
@@ -1380,7 +1380,6 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 		iph2 = ip_hdr(p);
 
 		if ((iph->protocol ^ iph2->protocol) |
-		    (iph->tos ^ iph2->tos) |
 		    ((__force u32)iph->saddr ^ (__force u32)iph2->saddr) |
 		    ((__force u32)iph->daddr ^ (__force u32)iph2->daddr)) {
 			NAPI_GRO_CB(p)->same_flow = 0;
@@ -1390,6 +1389,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 		/* All fields must match except length and checksum. */
 		NAPI_GRO_CB(p)->flush |=
 			(iph->ttl ^ iph2->ttl) |
+			(iph->tos ^ iph2->tos) |
 			((u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) ^ id);
 
 		NAPI_GRO_CB(p)->flush |= flush;
