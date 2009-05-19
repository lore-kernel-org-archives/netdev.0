From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH 2/5] sit: strictly restrict incoming traffic to tunnel link device
Date: Tue, 19 May 2009 23:03:40 +0200
Message-ID: <1242767023-9501-2-git-send-email-contact@saschahlusiak.de>
References: <1242767023-9501-1-git-send-email-contact@saschahlusiak.de>
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:63515 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754385AbZESVHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 17:07:09 -0400
In-Reply-To: <1242767023-9501-1-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check link device when looking up a tunnel. When a tunnel is
linked to a interface, traffic from a different interface must not
reach the tunnel.

This also allows creating of multiple tunnels with the same
endpoints, if the link device differs.

Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
---
 net/ipv6/sit.c |   30 +++++++++++++++++++++---------
 1 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index e625041..dfedd56 100644
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
@@ -89,18 +89,25 @@ static struct ip_tunnel * ipip6_tunnel_lookup(struct net *net,
 
 	for (t = sitn->tunnels_r_l[h0^h1]; t; t = t->next) {
 		if (local == t->parms.iph.saddr &&
-		    remote == t->parms.iph.daddr && (t->dev->flags&IFF_UP))
+		    remote == t->parms.iph.daddr &&
+		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
+		    (t->dev->flags & IFF_UP))
 			return t;
 	}
 	for (t = sitn->tunnels_r[h0]; t; t = t->next) {
-		if (remote == t->parms.iph.daddr && (t->dev->flags&IFF_UP))
+		if (remote == t->parms.iph.daddr &&
+		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
+		    (t->dev->flags & IFF_UP))
 			return t;
 	}
 	for (t = sitn->tunnels_l[h1]; t; t = t->next) {
-		if (local == t->parms.iph.saddr && (t->dev->flags&IFF_UP))
+		if (local == t->parms.iph.saddr &&
+		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
+		    (t->dev->flags & IFF_UP))
 			return t;
 	}
-	if ((t = sitn->tunnels_wc[0]) != NULL && (t->dev->flags&IFF_UP))
+	t = sitn->tunnels_wc[0];
+	if ((t != NULL) && (t->dev->flags & IFF_UP))
 		return t;
 	return NULL;
 }
@@ -166,7 +173,8 @@ static struct ip_tunnel * ipip6_tunnel_locate(struct net *net,
 
 	for (tp = __ipip6_bucket(sitn, parms); (t = *tp) != NULL; tp = &t->next) {
 		if (local == t->parms.iph.saddr &&
-		    remote == t->parms.iph.daddr) {
+		    remote == t->parms.iph.daddr &&
+		    parms->link == t->parms.link) {
 			if (create)
 				return NULL;
 			else
@@ -451,7 +459,10 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 	err = -ENOENT;
 
 	read_lock(&ipip6_lock);
-	t = ipip6_tunnel_lookup(dev_net(skb->dev), iph->daddr, iph->saddr);
+	t = ipip6_tunnel_lookup(dev_net(skb->dev),
+				skb->dev,
+				iph->daddr,
+				iph->saddr);
 	if (t == NULL || t->parms.iph.daddr == 0)
 		goto out;
 
@@ -486,8 +497,9 @@ static int ipip6_rcv(struct sk_buff *skb)
 	iph = ip_hdr(skb);
 
 	read_lock(&ipip6_lock);
-	if ((tunnel = ipip6_tunnel_lookup(dev_net(skb->dev),
-					iph->saddr, iph->daddr)) != NULL) {
+	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
+				     iph->saddr, iph->daddr);
+	if (tunnel != NULL) {
 		secpath_reset(skb);
 		skb->mac_header = skb->network_header;
 		skb_reset_network_header(skb);
-- 
1.6.3

