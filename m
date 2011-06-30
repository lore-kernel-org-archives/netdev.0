From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/3] ipv4: Don't use ufo handling on later transformed
 packets
Date: Thu, 30 Jun 2011 11:19:32 +0200
Message-ID: <20110630091932.GC13201@secunet.com>
References: <20110630091820.GB13201@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51301 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752637Ab1F3JSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2011 05:18:54 -0400
Content-Disposition: inline
In-Reply-To: <20110630091820.GB13201@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We might call ip_ufo_append_data() for packets that will be IPsec
transformed later. This function should be used just for real
udp packets. So we check for rt->dst.header_len which is only
nonzero on IPsec handling and call ip_ufo_append_data() just
if rt->dst.header_len is zero.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4a7e16b..84f26e8 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -828,7 +828,7 @@ static int __ip_append_data(struct sock *sk,
 	cork->length += length;
 	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
-	    (rt->dst.dev->features & NETIF_F_UFO)) {
+	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len) {
 		err = ip_ufo_append_data(sk, queue, getfrag, from, length,
 					 hh_len, fragheaderlen, transhdrlen,
 					 mtu, flags);
-- 
1.7.0.4

