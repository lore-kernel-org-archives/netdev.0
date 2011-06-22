From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/2] ipv4: Fix IPsec slowpath fragmentation problem
Date: Wed, 22 Jun 2011 13:05:37 +0200
Message-ID: <20110622110537.GH6489@secunet.com>
References: <20110622110437.GG6489@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51890 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753210Ab1FVLFc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 07:05:32 -0400
Content-Disposition: inline
In-Reply-To: <20110622110437.GG6489@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_append_data() builds packets based on the mtu from dst_mtu(rt->dst.path).
On IPsec the effective mtu is lower because we need to add the protocol
headers and trailers later when we do the IPsec transformations. So after
the IPsec transformations the packet might be too big, which leads to a
slowpath fragmentation then. This patch fixes this by building the packets
based on the lower IPsec mtu from dst_mtu(&rt->dst) and adapts the exthdr
handling to this.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_output.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 6b894d4..4a7e16b 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -802,8 +802,6 @@ static int __ip_append_data(struct sock *sk,
 	skb = skb_peek_tail(queue);
 
 	exthdrlen = !skb ? rt->dst.header_len : 0;
-	length += exthdrlen;
-	transhdrlen += exthdrlen;
 	mtu = cork->fragsize;
 
 	hh_len = LL_RESERVED_SPACE(rt->dst.dev);
@@ -883,6 +881,8 @@ alloc_new_skb:
 			else
 				alloclen = fraglen;
 
+			alloclen += exthdrlen;
+
 			/* The last fragment gets additional space at tail.
 			 * Note, with MSG_MORE we overallocate on fragments,
 			 * because we have no idea what fragment will be
@@ -923,11 +923,11 @@ alloc_new_skb:
 			/*
 			 *	Find where to start putting bytes.
 			 */
-			data = skb_put(skb, fraglen);
+			data = skb_put(skb, fraglen + exthdrlen);
 			skb_set_network_header(skb, exthdrlen);
 			skb->transport_header = (skb->network_header +
 						 fragheaderlen);
-			data += fragheaderlen;
+			data += fragheaderlen + exthdrlen;
 
 			if (fraggap) {
 				skb->csum = skb_copy_and_csum_bits(
@@ -1061,7 +1061,7 @@ static int ip_setup_cork(struct sock *sk, struct inet_cork *cork,
 	 */
 	*rtp = NULL;
 	cork->fragsize = inet->pmtudisc == IP_PMTUDISC_PROBE ?
-			 rt->dst.dev->mtu : dst_mtu(rt->dst.path);
+			 rt->dst.dev->mtu : dst_mtu(&rt->dst);
 	cork->dst = &rt->dst;
 	cork->length = 0;
 	cork->tx_flags = ipc->tx_flags;
-- 
1.7.0.4

