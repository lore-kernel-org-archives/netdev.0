From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH] gre: strict physical device binding
Date: Thu, 22 Jan 2009 09:24:44 +0200
Message-ID: <1232609084-566-1-git-send-email-timo.teras@iki.fi>
Cc: Timo Teras <timo.teras@iki.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:5346 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753929AbZAVHYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 02:24:52 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2056030fgg.17
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2009 23:24:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check the device on receive path and allow otherwise identical devices
as long as the physical device differs.

This is useful for NBMA tunnels, where you want to use different gre IP
for each public IP available via different physical devices.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---
Updated as requested. Compile tested.
Sent as new patch since I haven't seen the earlier patch pushed yet.

 net/ipv4/ip_gre.c |  131 ++++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 95 insertions(+), 36 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0101521..07a188a 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -164,67 +164,124 @@ static DEFINE_RWLOCK(ipgre_lock);
 
 /* Given src, dst and key, find appropriate for input tunnel. */
 
-static struct ip_tunnel * ipgre_tunnel_lookup(struct net *net,
+static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
 					      __be32 remote, __be32 local,
 					      __be32 key, __be16 gre_proto)
 {
+	struct net *net = dev_net(dev);
+	int link = dev->ifindex;
 	unsigned h0 = HASH(remote);
 	unsigned h1 = HASH(key);
-	struct ip_tunnel *t;
-	struct ip_tunnel *t2 = NULL;
+	struct ip_tunnel *t, *cand = NULL;
 	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 	int dev_type = (gre_proto == htons(ETH_P_TEB)) ?
 		       ARPHRD_ETHER : ARPHRD_IPGRE;
+	int score, cand_score = 4;
 
 	for (t = ign->tunnels_r_l[h0^h1]; t; t = t->next) {
-		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr) {
-			if (t->parms.i_key == key && t->dev->flags & IFF_UP) {
-				if (t->dev->type == dev_type)
-					return t;
-				if (t->dev->type == ARPHRD_IPGRE && !t2)
-					t2 = t;
-			}
+		if (local != t->parms.iph.saddr ||
+		    remote != t->parms.iph.daddr ||
+		    key != t->parms.i_key ||
+		    !(t->dev->flags & IFF_UP))
+			continue;
+
+		if (t->dev->type != ARPHRD_IPGRE &&
+		    t->dev->type != dev_type)
+			continue;
+
+		score = 0;
+		if (t->parms.link != link)
+			score |= 1;
+		if (t->dev->type != dev_type)
+			score |= 2;
+		if (score == 0)
+			return t;
+
+		if (score < cand_score) {
+			cand = t;
+			cand_score = score;
 		}
 	}
 
 	for (t = ign->tunnels_r[h0^h1]; t; t = t->next) {
-		if (remote == t->parms.iph.daddr) {
-			if (t->parms.i_key == key && t->dev->flags & IFF_UP) {
-				if (t->dev->type == dev_type)
-					return t;
-				if (t->dev->type == ARPHRD_IPGRE && !t2)
-					t2 = t;
-			}
+		if (remote != t->parms.iph.daddr ||
+		    key != t->parms.i_key ||
+		    !(t->dev->flags & IFF_UP))
+			continue;
+
+		if (t->dev->type != ARPHRD_IPGRE &&
+		    t->dev->type != dev_type)
+			continue;
+
+		score = 0;
+		if (t->parms.link != link)
+			score |= 1;
+		if (t->dev->type != dev_type)
+			score |= 2;
+		if (score == 0)
+			return t;
+
+		if (score < cand_score) {
+			cand = t;
+			cand_score = score;
 		}
 	}
 
 	for (t = ign->tunnels_l[h1]; t; t = t->next) {
-		if (local == t->parms.iph.saddr ||
-		     (local == t->parms.iph.daddr &&
-		      ipv4_is_multicast(local))) {
-			if (t->parms.i_key == key && t->dev->flags & IFF_UP) {
-				if (t->dev->type == dev_type)
-					return t;
-				if (t->dev->type == ARPHRD_IPGRE && !t2)
-					t2 = t;
-			}
+		if ((local != t->parms.iph.saddr &&
+		     (local != t->parms.iph.daddr ||
+		      !ipv4_is_multicast(local))) ||
+		    key != t->parms.i_key ||
+		    !(t->dev->flags & IFF_UP))
+			continue;
+
+		if (t->dev->type != ARPHRD_IPGRE &&
+		    t->dev->type != dev_type)
+			continue;
+
+		score = 0;
+		if (t->parms.link != link)
+			score |= 1;
+		if (t->dev->type != dev_type)
+			score |= 2;
+		if (score == 0)
+			return t;
+
+		if (score < cand_score) {
+			cand = t;
+			cand_score = score;
 		}
 	}
 
 	for (t = ign->tunnels_wc[h1]; t; t = t->next) {
-		if (t->parms.i_key == key && t->dev->flags & IFF_UP) {
-			if (t->dev->type == dev_type)
-				return t;
-			if (t->dev->type == ARPHRD_IPGRE && !t2)
-				t2 = t;
+		if (t->parms.i_key != key ||
+		    !(t->dev->flags & IFF_UP))
+			continue;
+
+		if (t->dev->type != ARPHRD_IPGRE &&
+		    t->dev->type != dev_type)
+			continue;
+
+		score = 0;
+		if (t->parms.link != link)
+			score |= 1;
+		if (t->dev->type != dev_type)
+			score |= 2;
+		if (score == 0)
+			return t;
+
+		if (score < cand_score) {
+			cand = t;
+			cand_score = score;
 		}
 	}
 
-	if (t2)
-		return t2;
+	if (cand != NULL)
+		return cand;
 
-	if (ign->fb_tunnel_dev->flags&IFF_UP)
+	if (ign->fb_tunnel_dev->flags & IFF_UP)
 		return netdev_priv(ign->fb_tunnel_dev);
+
 	return NULL;
 }
 
@@ -284,6 +341,7 @@ static struct ip_tunnel *ipgre_tunnel_find(struct net *net,
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
 	__be32 key = parms->i_key;
+	int link = parms->link;
 	struct ip_tunnel *t, **tp;
 	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 
@@ -291,6 +349,7 @@ static struct ip_tunnel *ipgre_tunnel_find(struct net *net,
 		if (local == t->parms.iph.saddr &&
 		    remote == t->parms.iph.daddr &&
 		    key == t->parms.i_key &&
+		    link == t->parms.link &&
 		    type == t->dev->type)
 			break;
 
@@ -421,7 +480,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 	}
 
 	read_lock(&ipgre_lock);
-	t = ipgre_tunnel_lookup(dev_net(skb->dev), iph->daddr, iph->saddr,
+	t = ipgre_tunnel_lookup(skb->dev, iph->daddr, iph->saddr,
 				flags & GRE_KEY ?
 				*(((__be32 *)p) + (grehlen / 4) - 1) : 0,
 				p[1]);
@@ -518,7 +577,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 	gre_proto = *(__be16 *)(h + 2);
 
 	read_lock(&ipgre_lock);
-	if ((tunnel = ipgre_tunnel_lookup(dev_net(skb->dev),
+	if ((tunnel = ipgre_tunnel_lookup(skb->dev,
 					  iph->saddr, iph->daddr, key,
 					  gre_proto))) {
 		struct net_device_stats *stats = &tunnel->dev->stats;
-- 
1.5.6.3

