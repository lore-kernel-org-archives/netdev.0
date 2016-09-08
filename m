From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/6] net/xfrm_input: fix possible NULL deref of tunnel.ip6->parms.i_key
Date: Thu, 8 Sep 2016 08:29:14 +0200
Message-ID: <1473316155-12186-6-git-send-email-steffen.klassert@secunet.com>
References: <1473316155-12186-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35808 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751981AbcIHG33 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:29:29 -0400
In-Reply-To: <1473316155-12186-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kodanev <alexey.kodanev@oracle.com>

Running LTP 'icmp-uni-basic.sh -6 -p ipcomp -m tunnel' test over
openvswitch + veth can trigger kernel panic:

  BUG: unable to handle kernel NULL pointer dereference
  at 00000000000000e0 IP: [<ffffffff8169d1d2>] xfrm_input+0x82/0x750
  ...
  [<ffffffff816d472e>] xfrm6_rcv_spi+0x1e/0x20
  [<ffffffffa082c3c2>] xfrm6_tunnel_rcv+0x42/0x50 [xfrm6_tunnel]
  [<ffffffffa082727e>] tunnel6_rcv+0x3e/0x8c [tunnel6]
  [<ffffffff8169f365>] ip6_input_finish+0xd5/0x430
  [<ffffffff8169fc53>] ip6_input+0x33/0x90
  [<ffffffff8169f1d5>] ip6_rcv_finish+0xa5/0xb0
  ...

It seems that tunnel.ip6 can have garbage values and also dereferenced
without a proper check, only tunnel.ip4 is being verified. Fix it by
adding one more if block for AF_INET6 and initialize tunnel.ip6 with NULL
inside xfrm6_rcv_spi() (which is similar to xfrm4_rcv_spi()).

Fixes: 049f8e2 ("xfrm: Override skb->mark with tunnel->parm.i_key in xfrm_input")

Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_input.c |  1 +
 net/xfrm/xfrm_input.c  | 14 +++++++-------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 0eaab1f..00a2d40 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -23,6 +23,7 @@ int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 
 int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 {
+	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6 = NULL;
 	XFRM_SPI_SKB_CB(skb)->family = AF_INET6;
 	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct ipv6hdr, daddr);
 	return xfrm_input(skb, nexthdr, spi, 0);
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 1c4ad47..6e3f025 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -207,15 +207,15 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	family = XFRM_SPI_SKB_CB(skb)->family;
 
 	/* if tunnel is present override skb->mark value with tunnel i_key */
-	if (XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4) {
-		switch (family) {
-		case AF_INET:
+	switch (family) {
+	case AF_INET:
+		if (XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4)
 			mark = be32_to_cpu(XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4->parms.i_key);
-			break;
-		case AF_INET6:
+		break;
+	case AF_INET6:
+		if (XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6)
 			mark = be32_to_cpu(XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6->parms.i_key);
-			break;
-		}
+		break;
 	}
 
 	/* Allocate new secpath or COW existing one. */
-- 
1.9.1
