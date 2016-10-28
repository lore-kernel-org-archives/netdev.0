From: Eli Cooper <elicooper@gmx.com>
Subject: [PATCH v2] ip6_tunnel: Clear IP6CB in ip6_tnl_xmit() after encapsulation
Date: Fri, 28 Oct 2016 09:52:41 +0800
Message-ID: <20161028015241.23258-1-elicooper@gmx.com>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:61950 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034160AbcJ1Bwy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 21:52:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->cb may contain data from previous layers. In the observed scenario,
the garbage data were misinterpreted as IP6CB(skb)->frag_max_size, so
that small packets sent through the tunnel are mistakenly fragmented.

This patch clears the control buffer for the next layer, after an IPv6
header is installed.

Signed-off-by: Eli Cooper <elicooper@gmx.com>
---
v2: clears the whole IP6CB altogether and does it after encapsulation

 net/ipv6/ip6_tunnel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 202d16a..1487e17 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1174,6 +1174,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 
 	skb_push(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
+	memset(skb->cb, 0, sizeof(struct inet6_skb_parm));
 	ipv6h = ipv6_hdr(skb);
 	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
 		     ip6_make_flowlabel(net, skb, fl6->flowlabel, true, fl6));
-- 
2.10.1
