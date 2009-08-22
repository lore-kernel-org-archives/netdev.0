From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH] sit: 6to4: honour routing table
Date: Sat, 22 Aug 2009 12:47:52 +0200
Message-ID: <1250938072-5577-1-git-send-email-contact@saschahlusiak.de>
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:56404 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755484AbZHVKqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2009 06:46:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using only the actual destination address to determine the IPv4 target in
try_6to4(&iph6->daddr) seems wrong to me and breaks, if a 6to4 address is
the next-hop, like ::192.88.99.1 written as 6to4:

default via 2002:c058:6301:: dev 6to4

A package to 2001:: would fall through the try_6to4 check to the
IPv4-compat check and die there.

This patch makes try_6to4 use the address of the Next-Hop instead, respecting
the routing table. Users are encouraged to have a route 2002::/16 to the
tunnel device anyway, making all other 6to4 hosts direct neighbours.

Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
---
 net/ipv6/sit.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 98b7327..8ae3028 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -656,8 +656,17 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto tx_error;
 	}
 
-	if (!dst)
-		dst = try_6to4(&iph6->daddr);
+	if (!dst) {
+		struct neighbour *neigh = NULL;
+
+		if (skb_dst(skb))
+			neigh = skb_dst(skb)->neighbour;
+
+		if (neigh) {
+			addr6 = (struct in6_addr *)&neigh->primary_key;
+			dst = try_6to4(addr6);
+		}
+	}
 
 	if (!dst) {
 		struct neighbour *neigh = NULL;
-- 
1.6.4

