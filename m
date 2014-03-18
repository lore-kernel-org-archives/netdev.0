From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 12/13] vti6: Check the tunnel endpoints of the xfrm state and the vti interface
Date: Tue, 18 Mar 2014 08:21:37 +0100
Message-ID: <1395127298-24083-13-git-send-email-steffen.klassert@secunet.com>
References: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53252 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546AbaCRHV7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:21:59 -0400
In-Reply-To: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tunnel endpoints of the xfrm_state we got from the xfrm_lookup
must match the tunnel endpoints of the vti interface. This patch
ensures this matching.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_vti.c |   25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 8d189aa..6085793 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -376,6 +376,29 @@ vti6_addr_conflict(const struct ip6_tnl *t, const struct ipv6hdr *hdr)
 	return ipv6_addr_equal(&t->parms.raddr, &hdr->saddr);
 }
 
+static bool vti6_state_check(const struct xfrm_state *x,
+			     const struct in6_addr *dst,
+			     const struct in6_addr *src)
+{
+	xfrm_address_t *daddr = (xfrm_address_t *)dst;
+	xfrm_address_t *saddr = (xfrm_address_t *)src;
+
+	/* if there is no transform then this tunnel is not functional.
+	 * Or if the xfrm is not mode tunnel.
+	 */
+	if (!x || x->props.mode != XFRM_MODE_TUNNEL ||
+	    x->props.family != AF_INET6)
+		return false;
+
+	if (ipv6_addr_any(dst))
+		return xfrm_addr_equal(saddr, &x->props.saddr, AF_INET6);
+
+	if (!xfrm_state_addr_check(x, daddr, saddr, AF_INET6))
+		return false;
+
+	return true;
+}
+
 /**
  * vti6_xmit - send a packet
  *   @skb: the outgoing socket buffer
@@ -402,7 +425,7 @@ vti6_xmit(struct sk_buff *skb, struct net_device *dev, struct flowi *fl)
 		goto tx_err_link_failure;
 	}
 
-	if (!dst->xfrm || dst->xfrm->props.mode != XFRM_MODE_TUNNEL)
+	if (!vti6_state_check(dst->xfrm, &t->parms.raddr, &t->parms.laddr))
 		goto tx_err_link_failure;
 
 	tdev = dst->dev;
-- 
1.7.9.5
