From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH ipsec 2/2] ipv6: set skb->protocol on tcp, raw and ip6_append_data genereated skbs
Date: Thu, 22 Aug 2013 21:54:06 +0200
Message-ID: <20130822195406.GA4745@order.stressinduktion.org>
References: <20130822104724.GD26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40504 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066Ab3HVTyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 15:54:08 -0400
Content-Disposition: inline
In-Reply-To: <20130822104724.GD26773@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we don't initialize skb->protocol when transmitting data via
tcp, raw(with and without inclhdr) or udp+ufo or appending data directly
to the socket transmit queue (via ip6_append_data). This needs to be
done so that we can get the correct mtu in the xfrm layer.

Setting of skb->protocol happens only in functions where we also have
a transmitting socket and a new skb, so we don't overwrite old values.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

I would love to have more reviews for this. I hope to have checked all
the code-paths down from these routines to not cause any side-effects.

Testing showed no problems here. Sorry for only testing with udp only
before.

 net/ipv6/ip6_output.c | 3 +++
 net/ipv6/raw.c        | 1 +
 2 files changed, 4 insertions(+)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6e3ddf8..e7ceb6c 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -238,6 +238,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	hdr->saddr = fl6->saddr;
 	hdr->daddr = *first_hop;
 
+	skb->protocol = htons(ETH_P_IPV6);
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 
@@ -1057,6 +1058,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 		/* initialize protocol header pointer */
 		skb->transport_header = skb->network_header + fragheaderlen;
 
+		skb->protocol = htons(ETH_P_IPV6);
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum = 0;
 	}
@@ -1359,6 +1361,7 @@ alloc_new_skb:
 			/*
 			 *	Fill in the control structures
 			 */
+			skb->protocol = htons(ETH_P_IPV6);
 			skb->ip_summed = CHECKSUM_NONE;
 			skb->csum = 0;
 			/* reserve for fragmentation and ipsec header */
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index c45f7a5..cdaed47 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -628,6 +628,7 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 		goto error;
 	skb_reserve(skb, hlen);
 
+	skb->protocol = htons(ETH_P_IPV6);
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 	skb_dst_set(skb, &rt->dst);
-- 
1.8.3.1
