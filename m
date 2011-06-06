From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/3] ipv4: Fix packet size calculation for raw IPsec
 packets in __ip_append_data
Date: Mon, 6 Jun 2011 08:48:47 +0200
Message-ID: <20110606064847.GD31505@secunet.com>
References: <20110606064603.GB31505@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54577 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752940Ab1FFGp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 02:45:27 -0400
Content-Disposition: inline
In-Reply-To: <20110606064603.GB31505@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We assume that transhdrlen is positive on the first fragment
which is wrong for raw packets. So we don't add exthdrlen to the
packet size for raw packets. This leads to a reallocation on IPsec
because we have not enough headroom on the skb to place the IPsec
headers. This patch fixes this by adding exthdrlen to the packet
size whenever the send queue of the socket is empty. This issue was
introduced with git commit 1470ddf7 (inet: Remove explicit write
references to sk/inet in ip_append_data)

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_output.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index a16859b..6b894d4 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -799,7 +799,9 @@ static int __ip_append_data(struct sock *sk,
 	int csummode = CHECKSUM_NONE;
 	struct rtable *rt = (struct rtable *)cork->dst;
 
-	exthdrlen = transhdrlen ? rt->dst.header_len : 0;
+	skb = skb_peek_tail(queue);
+
+	exthdrlen = !skb ? rt->dst.header_len : 0;
 	length += exthdrlen;
 	transhdrlen += exthdrlen;
 	mtu = cork->fragsize;
@@ -825,8 +827,6 @@ static int __ip_append_data(struct sock *sk,
 	    !exthdrlen)
 		csummode = CHECKSUM_PARTIAL;
 
-	skb = skb_peek_tail(queue);
-
 	cork->length += length;
 	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
-- 
1.7.0.4

