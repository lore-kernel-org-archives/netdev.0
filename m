From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] esp: skip GRO for fragmented packets
Date: Thu, 27 Apr 2017 12:31:14 +0200
Message-ID: <37d07f4c9bfaf9733d3cd90653927540e2639d39.1493288951.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57020 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755406AbdD0Kb2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 06:31:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, ESP4 GRO doesn't work for fragmented packets, so let's send
these through the normal path.

Fixes: 7785bba299a8 ("esp: Add a software GRO codepath")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
Steffen, if you prefer to drop this patch and fix this properly,
that's okay for me. I can't look much deeper into this right now and
it's broken on current net/master.

It seems like the first fragment gets dropped, at least I don't see it
on tcpdump on the RX machine.

 net/ipv4/esp4_offload.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
index 1de442632406..ab5faca28e19 100644
--- a/net/ipv4/esp4_offload.c
+++ b/net/ipv4/esp4_offload.c
@@ -38,6 +38,9 @@ static struct sk_buff **esp4_gro_receive(struct sk_buff **head,
 	__be32 spi;
 	int err;
 
+	if (ip_is_fragment(ip_hdr(skb)))
+		goto flush;
+
 	skb_pull(skb, offset);
 
 	if ((err = xfrm_parse_spi(skb, IPPROTO_ESP, &spi, &seq)) != 0)
@@ -78,6 +81,7 @@ static struct sk_buff **esp4_gro_receive(struct sk_buff **head,
 	return ERR_PTR(-EINPROGRESS);
 out:
 	skb_push(skb, offset);
+flush:
 	NAPI_GRO_CB(skb)->same_flow = 0;
 	NAPI_GRO_CB(skb)->flush = 1;
 
-- 
2.12.2
