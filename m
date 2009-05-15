From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH 2/5] sit: strictly restrict incoming traffic to tunnel link device
Date: Fri, 15 May 2009 14:52:48 +0200
Message-ID: <1242391971-32583-2-git-send-email-contact@saschahlusiak.de>
References: <1242391971-32583-1-git-send-email-contact@saschahlusiak.de>
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:64352 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754917AbZEOMwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 08:52:13 -0400
In-Reply-To: <1242391971-32583-1-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check link device when looking up a tunnel. When a tunnel is
linked to a interface, traffic from a different interface must not
reach the tunnel.

This also allows creating of multiple tunnels with the same
endpoints, if the link device differs.
---
 net/ipv6/sit.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index bd63a7e..dc73d6a 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -80,7 +80,7 @@ struct sit_net {
 static DEFINE_RWLOCK(ipip6_lock);
 
 static struct ip_tunnel * ipip6_tunnel_lookup(struct net *net,
-		__be32 remote, __be32 local)
+		struct net_device *dev, __be32 remote, __be32 local)
 {
 	unsigned h0 = HASH(remote);
 	unsigned h1 = HASH(local);
@@ -89,15 +89,21 @@ static struct ip_tunnel * ipip6_tunnel_lookup(struct net *net,
 
 	for (t = sitn->tunnels_r_l[h0^h1]; t; t = t->next) {
 		if (local == t->parms.iph.saddr &&
-		    remote == t->parms.iph.daddr && (t->dev->flags&IFF_UP))
+		    remote == t->parms.iph.daddr &&
+		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
+		    (t->dev->flags&IFF_UP))
 			return t;
 	}
 	for (t = sitn->tunnels_r[h0]; t; t = t->next) {
-		if (remote == t->parms.iph.daddr && (t->dev->flags&IFF_UP))
+		if (remote == t->parms.iph.daddr &&
+		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
+		    (t->dev->flags&IFF_UP))
 			return t;
 	}
 	for (t = sitn->tunnels_l[h1]; t; t = t->next) {
-		if (local == t->parms.iph.saddr && (t->dev->flags&IFF_UP))
+		if (local == t->parms.iph.saddr &&
+		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
+		    (t->dev->flags&IFF_UP))
 			return t;
 	}
 	if ((t = sitn->tunnels_wc[0]) != NULL && (t->dev->flags&IFF_UP))
@@ -165,7 +171,9 @@ static struct ip_tunnel * ipip6_tunnel_locate(struct net *net,
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
 	for (tp = __ipip6_bucket(sitn, parms); (t = *tp) != NULL; tp = &t->next) {
-		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr) {
+		if (local == t->parms.iph.saddr &&
+		    remote == t->parms.iph.daddr &&
+		    parms->link == t->parms.link) {
 			if (create)
 				return NULL;
 			else 	return t;
@@ -449,7 +457,10 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 	err = -ENOENT;
 
 	read_lock(&ipip6_lock);
-	t = ipip6_tunnel_lookup(dev_net(skb->dev), iph->daddr, iph->saddr);
+	t = ipip6_tunnel_lookup(dev_net(skb->dev),
+				skb->dev,
+				iph->daddr,
+				iph->saddr);
 	if (t == NULL || t->parms.iph.daddr == 0)
 		goto out;
 
@@ -484,7 +495,7 @@ static int ipip6_rcv(struct sk_buff *skb)
 	iph = ip_hdr(skb);
 
 	read_lock(&ipip6_lock);
-	if ((tunnel = ipip6_tunnel_lookup(dev_net(skb->dev),
+	if ((tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
 					iph->saddr, iph->daddr)) != NULL) {
 		secpath_reset(skb);
 		skb->mac_header = skb->network_header;
-- 
1.6.3

