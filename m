From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/12] [IPSEC]: Fix pure tunnel modes involving IPv6
Date: Tue, 16 Oct 2007 22:33:09 +0800
Message-ID: <E1IhnTp-0003GE-00@gondolin.me.apana.org.au>
References: <20071016141843.GA11956@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2983 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932480AbXJPOxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:53:03 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1Ihnn3-0001GY-SM
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 00:53:02 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Fix pure tunnel modes involving IPv6

I noticed that my recent patch broke 6-on-4 pure IPsec tunnels (the ones
that are only used for incompressible IPsec packets).  Subsequent reviews
show that I broke 6-on-6 pure tunnels more than three years ago and nobody
ever noticed. I suppose every must be testing 6-on-6 IPComp with large
pings which are very compressible :)

This patch fixes both cases.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/xfrm4_tunnel.c |    2 +-
 net/ipv6/xfrm6_tunnel.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index 1312417..83e9580 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -18,7 +18,7 @@ static int ipip_output(struct xfrm_state *x, struct sk_buff *skb)
 
 static int ipip_xfrm_rcv(struct xfrm_state *x, struct sk_buff *skb)
 {
-	return IPPROTO_IP;
+	return ip_hdr(skb)->protocol;
 }
 
 static int ipip_init_state(struct xfrm_state *x)
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 3f8a3ab..6c67ac1 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -248,7 +248,7 @@ static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 
 static int xfrm6_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-	return 0;
+	return skb_network_header(skb)[IP6CB(skb)->nhoff];
 }
 
 static int xfrm6_tunnel_rcv(struct sk_buff *skb)
