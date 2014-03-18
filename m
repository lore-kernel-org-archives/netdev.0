From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 08/13] vti6: Remove caching of flow informations.
Date: Tue, 18 Mar 2014 08:21:33 +0100
Message-ID: <1395127298-24083-9-git-send-email-steffen.klassert@secunet.com>
References: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53278 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753475AbaCRHV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:21:56 -0400
In-Reply-To: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike ip6_tunnel, vti6 does not use the the tunnel
endpoint addresses to do route and xfrm lookups.
So no need to cache the flow informations. It also
does not make sense to calculate the mtu based on
such flow informations, so remove this too.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_vti.c |   31 -------------------------------
 1 file changed, 31 deletions(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index f5ba4d4..cc4a758 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -443,19 +443,10 @@ static void vti6_link_config(struct ip6_tnl *t)
 	struct dst_entry *dst;
 	struct net_device *dev = t->dev;
 	struct __ip6_tnl_parm *p = &t->parms;
-	struct flowi6 *fl6 = &t->fl.u.ip6;
 
 	memcpy(dev->dev_addr, &p->laddr, sizeof(struct in6_addr));
 	memcpy(dev->broadcast, &p->raddr, sizeof(struct in6_addr));
 
-	/* Set up flowi template */
-	fl6->saddr = p->laddr;
-	fl6->daddr = p->raddr;
-	fl6->flowi6_oif = p->link;
-	fl6->flowi6_mark = be32_to_cpu(p->i_key);
-	fl6->flowi6_proto = p->proto;
-	fl6->flowlabel = 0;
-
 	p->flags &= ~(IP6_TNL_F_CAP_XMIT | IP6_TNL_F_CAP_RCV |
 		      IP6_TNL_F_CAP_PER_PACKET);
 	p->flags |= ip6_tnl_get_cap(t, &p->laddr, &p->raddr);
@@ -466,28 +457,6 @@ static void vti6_link_config(struct ip6_tnl *t)
 		dev->flags &= ~IFF_POINTOPOINT;
 
 	dev->iflink = p->link;
-
-	if (p->flags & IP6_TNL_F_CAP_XMIT) {
-
-		dst = ip6_route_output(dev_net(dev), NULL, fl6);
-		if (dst->error)
-			return;
-
-		dst = xfrm_lookup(dev_net(dev), dst, flowi6_to_flowi(fl6),
-				  NULL, 0);
-		if (IS_ERR(dst))
-			return;
-
-		if (dst->dev) {
-			dev->hard_header_len = dst->dev->hard_header_len;
-
-			dev->mtu = dst_mtu(dst);
-
-			if (dev->mtu < IPV6_MIN_MTU)
-				dev->mtu = IPV6_MIN_MTU;
-		}
-		dst_release(dst);
-	}
 }
 
 /**
-- 
1.7.9.5
