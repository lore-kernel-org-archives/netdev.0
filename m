From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH] sit: Fix ipip6_tunnel_lookup device matching criteria
Date: Thu, 14 Aug 2014 12:32:09 +0300
Message-ID: <1408008729-16982-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Sascha Hlusiak <contact@saschahlusiak.de>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:44919 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402AbaHNJcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 05:32:54 -0400
Received: by mail-wi0-f177.google.com with SMTP id ho1so1991063wib.4
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 02:32:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As of 4fddbf5d78, when looking up a tunnel, tunnel's underlying
interface (t->parms.link) is verified to match incoming traffic's
ingress device.

However the comparison was incorrectly based on skb->dev->iflink.

Instead, dev->ifindex should be used, which correctly represents the
interface from which the IP stack hands the ipip6 packets.

This allows setting up sit tunnels bound to vlan interfaces (otherwise
incoming ipip6 traffic on the vlan interface was dropped due to
ipip6_tunnel_lookup match failure).

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
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
