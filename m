From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][7/7] inter address family ipsec tunnel
Date: Fri, 24 Nov 2006 14:39:17 +0900
Message-ID: <20061124143917.604095d7.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:18905 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S934371AbWKXFn5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 00:43:57 -0500
To: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes mtu calculation and the check
for IPv6 datagram when the packet will be applied IPsec.

ip6_append_data should refer mtu of "dst"
because of the same reasone of the previous patch.

xfrm6_check_tunnel_size should use skb_headlen
because skb->len of fragmented packet is
total length of payload in packets.
we should check the length in a packet.

Signed-off-by: Miika Komu <miika@iki.fi>
Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>

---
 net/ipv6/ip6_output.c   |    2 +-
 net/ipv6/xfrm6_output.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e05ecbb..d3858cf 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1024,7 +1024,7 @@ int ip6_append_data(struct sock *sk, int
 		inet->cork.fl = *fl;
 		np->cork.hop_limit = hlimit;
 		np->cork.tclass = tclass;
-		mtu = dst_mtu(rt->u.dst.path);
+		mtu = dst_mtu(&rt->u.dst);
 		if (np->frag_size < mtu) {
 			if (np->frag_size)
 				mtu = np->frag_size;
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index c260ea1..53779fa 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -32,7 +32,7 @@ static int xfrm6_tunnel_check_size(struc
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
 
-	if (skb->len > mtu) {
+	if (skb_headlen(skb) > mtu) {
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
 		ret = -EMSGSIZE;
