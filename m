From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH v3] sit: Fix ipip6_tunnel_lookup device matching criteria
Date: Thu, 14 Aug 2014 15:27:20 +0300
Message-ID: <1408019240-17751-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Sascha Hlusiak <contact@saschahlusiak.de>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:52063 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368AbaHNM1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 08:27:45 -0400
Received: by mail-wg0-f45.google.com with SMTP id x12so994320wgg.4
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 05:27:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As of 4fddbf5d78 ("sit: strictly restrict incoming traffic to tunnel link device"),
when looking up a tunnel, tunnel's underlying interface (t->parms.link)
is verified to match incoming traffic's ingress device.

However the comparison was incorrectly based on skb->dev->iflink.

Instead, dev->ifindex should be used, which correctly represents the
interface from which the IP stack hands the ipip6 packets.

This allows setting up sit tunnels bound to vlan interfaces (otherwise
incoming ipip6 traffic on the vlan interface was dropped due to
ipip6_tunnel_lookup match failure).

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
v3: no splitting of quoted summary line

 net/ipv6/sit.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 2e9ba035fb..6163f851dc 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -101,19 +101,19 @@ static struct ip_tunnel *ipip6_tunnel_lookup(struct net *net,
 	for_each_ip_tunnel_rcu(t, sitn->tunnels_r_l[h0 ^ h1]) {
 		if (local == t->parms.iph.saddr &&
 		    remote == t->parms.iph.daddr &&
-		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
+		    (!dev || !t->parms.link || dev->ifindex == t->parms.link) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
 	for_each_ip_tunnel_rcu(t, sitn->tunnels_r[h0]) {
 		if (remote == t->parms.iph.daddr &&
-		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
+		    (!dev || !t->parms.link || dev->ifindex == t->parms.link) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
 	for_each_ip_tunnel_rcu(t, sitn->tunnels_l[h1]) {
 		if (local == t->parms.iph.saddr &&
-		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
+		    (!dev || !t->parms.link || dev->ifindex == t->parms.link) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
-- 
1.9.0
