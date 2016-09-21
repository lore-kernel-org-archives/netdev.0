From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/4] vti6: fix input path
Date: Wed, 21 Sep 2016 13:05:46 +0200
Message-ID: <1474455946-674-5-git-send-email-steffen.klassert@secunet.com>
References: <1474455946-674-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:38351 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754413AbcIULF6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 07:05:58 -0400
In-Reply-To: <1474455946-674-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Since commit 1625f4529957, vti6 is broken, all input packets are dropped
(LINUX_MIB_XFRMINNOSTATES is incremented).

XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6 is set by vti6_rcv() before calling
xfrm6_rcv()/xfrm6_rcv_spi(), thus we cannot set to NULL that value in
xfrm6_rcv_spi().

A new function xfrm6_rcv_tnl() that enables to pass a value to
xfrm6_rcv_spi() is added, so that xfrm6_rcv() is not touched (this function
is used in several handlers).

CC: Alexey Kodanev <alexey.kodanev@oracle.com>
Fixes: 1625f4529957 ("net/xfrm_input: fix possible NULL deref of tunnel.ip6->parms.i_key")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h      |  4 +++-
 net/ipv6/ip6_vti.c      |  4 +---
 net/ipv6/xfrm6_input.c  | 16 +++++++++++-----
 net/ipv6/xfrm6_tunnel.c |  2 +-
 4 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index adfebd6..1793431 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1540,8 +1540,10 @@ int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
 void xfrm4_local_error(struct sk_buff *skb, u32 mtu);
 int xfrm6_extract_header(struct sk_buff *skb);
 int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb);
-int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
+int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi,
+		  struct ip6_tnl *t);
 int xfrm6_transport_finish(struct sk_buff *skb, int async);
+int xfrm6_rcv_tnl(struct sk_buff *skb, struct ip6_tnl *t);
 int xfrm6_rcv(struct sk_buff *skb);
 int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 		     xfrm_address_t *saddr, u8 proto);
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 52a2f73..5bd3afd 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -321,11 +321,9 @@ static int vti6_rcv(struct sk_buff *skb)
 			goto discard;
 		}
 
-		XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6 = t;
-
 		rcu_read_unlock();
 
-		return xfrm6_rcv(skb);
+		return xfrm6_rcv_tnl(skb, t);
 	}
 	rcu_read_unlock();
 	return -EINVAL;
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 00a2d40..b578956 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -21,9 +21,10 @@ int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 	return xfrm6_extract_header(skb);
 }
 
-int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
+int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi,
+		  struct ip6_tnl *t)
 {
-	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6 = NULL;
+	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6 = t;
 	XFRM_SPI_SKB_CB(skb)->family = AF_INET6;
 	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct ipv6hdr, daddr);
 	return xfrm_input(skb, nexthdr, spi, 0);
@@ -49,13 +50,18 @@ int xfrm6_transport_finish(struct sk_buff *skb, int async)
 	return -1;
 }
 
-int xfrm6_rcv(struct sk_buff *skb)
+int xfrm6_rcv_tnl(struct sk_buff *skb, struct ip6_tnl *t)
 {
 	return xfrm6_rcv_spi(skb, skb_network_header(skb)[IP6CB(skb)->nhoff],
-			     0);
+			     0, t);
 }
-EXPORT_SYMBOL(xfrm6_rcv);
+EXPORT_SYMBOL(xfrm6_rcv_tnl);
 
+int xfrm6_rcv(struct sk_buff *skb)
+{
+	return xfrm6_rcv_tnl(skb, NULL);
+}
+EXPORT_SYMBOL(xfrm6_rcv);
 int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 		     xfrm_address_t *saddr, u8 proto)
 {
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 5743044..e1c0bbe 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -236,7 +236,7 @@ static int xfrm6_tunnel_rcv(struct sk_buff *skb)
 	__be32 spi;
 
 	spi = xfrm6_tunnel_spi_lookup(net, (const xfrm_address_t *)&iph->saddr);
-	return xfrm6_rcv_spi(skb, IPPROTO_IPV6, spi);
+	return xfrm6_rcv_spi(skb, IPPROTO_IPV6, spi, NULL);
 }
 
 static int xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-- 
1.9.1
