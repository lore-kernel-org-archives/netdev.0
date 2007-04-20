From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC] fix panic when using inter address familiy IPsec on
 loopback
Date: Fri, 20 Apr 2007 19:02:51 +0900
Message-ID: <20070420190251.292bea8a.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:41738 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754345AbXDTKC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2007 06:02:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I send patches to fix panic when using inter
address family IPsec on loopback device.

These patches can be applied to current linux-2.6 and
should also be net-2.6.

Best regards, 

Signed-off-by: Kazunori MIYAZAWA <kazunori@miyazawa.org>
---
 net/ipv4/xfrm4_input.c       |    6 ++----
 net/ipv4/xfrm4_mode_tunnel.c |    2 ++
 net/ipv6/xfrm6_input.c       |    6 ++----
 net/ipv6/xfrm6_mode_tunnel.c |    1 +
 4 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 78e80de..9fcf6d8 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -138,10 +138,8 @@ int xfrm4_rcv_encap(struct sk_buff *skb,
 	nf_reset(skb);
 
 	if (decaps) {
-		if (!(skb->dev->flags&IFF_LOOPBACK)) {
-			dst_release(skb->dst);
-			skb->dst = NULL;
-		}
+		dst_release(skb->dst);
+		skb->dst = NULL;
 		netif_rx(skb);
 		return 0;
 	} else {
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index ceb4376..5115574 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -84,6 +84,8 @@ #endif
 	top_iph->saddr = x->props.saddr.a4;
 	top_iph->daddr = x->id.daddr.a4;
 
+	skb->protocol = htons(ETH_P_IP);
+
 	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 	return 0;
 }
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 31f651f..c53c0d3 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -104,10 +104,8 @@ int xfrm6_rcv_spi(struct sk_buff *skb, _
 	nf_reset(skb);
 
 	if (decaps) {
-		if (!(skb->dev->flags&IFF_LOOPBACK)) {
-			dst_release(skb->dst);
-			skb->dst = NULL;
-		}
+		dst_release(skb->dst);
+		skb->dst = NULL;
 		netif_rx(skb);
 		return -1;
 	} else {
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 0bc866c..8741bcd 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -80,6 +80,7 @@ static int xfrm6_tunnel_output(struct xf
 	top_iph->hop_limit = dst_metric(dst->child, RTAX_HOPLIMIT);
 	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
 	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
+	skb->protocol = htons(ETH_P_IPV6);
 	return 0;
 }
 
-- 
1.4.1

