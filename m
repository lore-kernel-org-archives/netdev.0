From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 6/7] xfrm: Override skb->mark with tunnel->parm.i_key in xfrm_input
Date: Thu, 28 May 2015 09:28:09 +0200
Message-ID: <1432798090-20657-7-git-send-email-steffen.klassert@secunet.com>
References: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51245 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752917AbbE1H2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 03:28:32 -0400
In-Reply-To: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

This change makes it so that if a tunnel is defined we just use the mark
from the tunnel instead of the mark from the skb header.  By doing this we
can avoid the need to set skb->mark inside of the tunnel receive functions.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_input.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 526c4fe..b58286e 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -13,6 +13,8 @@
 #include <net/dst.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
+#include <net/ip_tunnels.h>
+#include <net/ip6_tunnel.h>
 
 static struct kmem_cache *secpath_cachep __read_mostly;
 
@@ -186,6 +188,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	struct xfrm_state *x = NULL;
 	xfrm_address_t *daddr;
 	struct xfrm_mode *inner_mode;
+	u32 mark = skb->mark;
 	unsigned int family;
 	int decaps = 0;
 	int async = 0;
@@ -203,6 +206,18 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 				   XFRM_SPI_SKB_CB(skb)->daddroff);
 	family = XFRM_SPI_SKB_CB(skb)->family;
 
+	/* if tunnel is present override skb->mark value with tunnel i_key */
+	if (XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4) {
+		switch (family) {
+		case AF_INET:
+			mark = be32_to_cpu(XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4->parms.i_key);
+			break;
+		case AF_INET6:
+			mark = be32_to_cpu(XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6->parms.i_key);
+			break;
+		}
+	}
+
 	/* Allocate new secpath or COW existing one. */
 	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
 		struct sec_path *sp;
@@ -229,7 +244,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			goto drop;
 		}
 
-		x = xfrm_state_lookup(net, skb->mark, daddr, spi, nexthdr, family);
+		x = xfrm_state_lookup(net, mark, daddr, spi, nexthdr, family);
 		if (x == NULL) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINNOSTATES);
 			xfrm_audit_state_notfound(skb, family, spi, seq);
-- 
1.9.1
