From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv6: check skb->protocol before lookup for nexthop
Date: Tue, 25 Apr 2017 14:37:15 -0700
Message-ID: <1493156235-9823-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Steffen Klassert <steffen.klassert@secunet.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32991 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1432128AbdDYVh0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 17:37:26 -0400
Received: by mail-io0-f194.google.com with SMTP id k87so55058967ioi.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 14:37:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey reported a out-of-bound access in ip6_tnl_xmit(), this
is because we use an ipv4 dst in ip6_tnl_xmit() and cast an IPv4
neigh key as an IPv6 address:

        neigh = dst_neigh_lookup(skb_dst(skb),
                                 &ipv6_hdr(skb)->daddr);
        if (!neigh)
                goto tx_err_link_failure;

        addr6 = (struct in6_addr *)&neigh->primary_key; // <=== HERE
        addr_type = ipv6_addr_type(addr6);

        if (addr_type == IPV6_ADDR_ANY)
                addr6 = &ipv6_hdr(skb)->daddr;

        memcpy(&fl6->daddr, addr6, sizeof(fl6->daddr));

Also the network header of the skb at this point should be still IPv4
for 4in6 tunnels, we shold not just use it as IPv6 header.

This patch fixes it by checking if skb->protocol is ETH_P_IPV6: if it
is, we are safe to do the nexthop lookup using skb_dst() and
ipv6_hdr(skb)->daddr; if not (aka IPv4), we have no clue about which
dest address we can pick here, we have to rely on callers to fill it
from tunnel config, so just fall to ip6_route_output() to make the
decision.

Fixes: ea3dc9601bda ("ip6_tunnel: Add support for wildcard tunnel endpoints.")
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/ip6_tunnel.c | 34 ++++++++++++++++++----------------
 1 file changed, 18 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 75fac93..a9692ec 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1037,7 +1037,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net *net = t->net;
 	struct net_device_stats *stats = &t->dev->stats;
-	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+	struct ipv6hdr *ipv6h;
 	struct ipv6_tel_txoption opt;
 	struct dst_entry *dst = NULL, *ndst = NULL;
 	struct net_device *tdev;
@@ -1057,26 +1057,28 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 
 	/* NBMA tunnel */
 	if (ipv6_addr_any(&t->parms.raddr)) {
-		struct in6_addr *addr6;
-		struct neighbour *neigh;
-		int addr_type;
+		if (skb->protocol == htons(ETH_P_IPV6)) {
+			struct in6_addr *addr6;
+			struct neighbour *neigh;
+			int addr_type;
 
-		if (!skb_dst(skb))
-			goto tx_err_link_failure;
+			if (!skb_dst(skb))
+				goto tx_err_link_failure;
 
-		neigh = dst_neigh_lookup(skb_dst(skb),
-					 &ipv6_hdr(skb)->daddr);
-		if (!neigh)
-			goto tx_err_link_failure;
+			neigh = dst_neigh_lookup(skb_dst(skb),
+						 &ipv6_hdr(skb)->daddr);
+			if (!neigh)
+				goto tx_err_link_failure;
 
-		addr6 = (struct in6_addr *)&neigh->primary_key;
-		addr_type = ipv6_addr_type(addr6);
+			addr6 = (struct in6_addr *)&neigh->primary_key;
+			addr_type = ipv6_addr_type(addr6);
 
-		if (addr_type == IPV6_ADDR_ANY)
-			addr6 = &ipv6_hdr(skb)->daddr;
+			if (addr_type == IPV6_ADDR_ANY)
+				addr6 = &ipv6_hdr(skb)->daddr;
 
-		memcpy(&fl6->daddr, addr6, sizeof(fl6->daddr));
-		neigh_release(neigh);
+			memcpy(&fl6->daddr, addr6, sizeof(fl6->daddr));
+			neigh_release(neigh);
+		}
 	} else if (!(t->parms.flags &
 		     (IP6_TNL_F_USE_ORIG_TCLASS | IP6_TNL_F_USE_ORIG_FWMARK))) {
 		/* enable the cache only only if the routing decision does
-- 
2.5.5
