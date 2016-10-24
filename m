From: Eli Cooper <elicooper@gmx.com>
Subject: [PATCH] ip6_tunnel: Clear IP6CB(skb)->frag_max_size in ip4ip6_tnl_xmit()
Date: Mon, 24 Oct 2016 23:07:12 +0800
Message-ID: <20161024150712.5133-1-elicooper@gmx.com>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:58718 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938646AbcJXPHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 11:07:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->cb may contain data from previous layers, as shown in 5146d1f1511
("tunnel: Clear IPCB(skb)->opt before dst_link_failure called").
However, for ipip6 tunnels, clearing IPCB(skb)->opt alone is not enough,
because skb->cb is later misinterpreted as IP6CB(skb)->frag_max_size.

In the observed scenario, the garbage data made the max fragment size so
so small that packets sent through the tunnel are mistakenly fragmented.

This patch clears IP6CB(skb)->frag_max_size for ipip6 tunnels.

Signed-off-by: Eli Cooper <elicooper@gmx.com>
---
 net/ipv6/ip6_tunnel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 202d16a..4110562 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1205,6 +1205,7 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	int err;
 
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+	IP6CB(skb)->frag_max_size = 0;
 
 	tproto = ACCESS_ONCE(t->parms.proto);
 	if (tproto != IPPROTO_IPIP && tproto != 0)
-- 
2.10.1
