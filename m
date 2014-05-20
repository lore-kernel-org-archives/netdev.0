From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net v2] ipv6: gro: fix CHECKSUM_COMPLETE support
Date: Mon, 19 May 2014 21:56:34 -0700
Message-ID: <1400561794.5367.89.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400548164.5367.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jerry Chu <hkchu@google.com>, netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:45502 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbaETE4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 00:56:36 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so6681578pbb.22
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 21:56:35 -0700 (PDT)
In-Reply-To: <1400548164.5367.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When GRE support was added in linux-3.14, CHECKSUM_COMPLETE handling
broke on GRE+IPv6 because we did not update/use the appropriate csum :

GRO layer is supposed to use/update NAPI_GRO_CB(skb)->csum instead of
skb->csum

Tested using a GRE tunnel and IPv6 traffic. GRO aggregation now happens
at the first level (ethernet device) instead of being done in gre
tunnel. Native IPv6+TCP is still properly aggregated.

Fixes: bf5a755f5e918 ("net-gre-gro: Add GRE support to the GRO stack")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jerry Chu <hkchu@google.com>
---
v2: use nlen instead of sizeof(*iph) to support extension headers

 net/ipv6/ip6_offload.c   |    6 +-----
 net/ipv6/tcpv6_offload.c |    2 +-
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 59f95affceb0..b2f091566f88 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -196,7 +196,6 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 	unsigned int off;
 	u16 flush = 1;
 	int proto;
-	__wsum csum;
 
 	off = skb_gro_offset(skb);
 	hlen = off + sizeof(*iph);
@@ -264,13 +263,10 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 
 	NAPI_GRO_CB(skb)->flush |= flush;
 
-	csum = skb->csum;
-	skb_postpull_rcsum(skb, iph, skb_network_header_len(skb));
+	skb_gro_postpull_rcsum(skb, iph, nlen);
 
 	pp = ops->callbacks.gro_receive(head, skb);
 
-	skb->csum = csum;
-
 out_unlock:
 	rcu_read_unlock();
 
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
index 0d78132ff18a..8517d3cd1aed 100644
--- a/net/ipv6/tcpv6_offload.c
+++ b/net/ipv6/tcpv6_offload.c
@@ -42,7 +42,7 @@ static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
 	if (NAPI_GRO_CB(skb)->flush)
 		goto skip_csum;
 
-	wsum = skb->csum;
+	wsum = NAPI_GRO_CB(skb)->csum;
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_NONE:
