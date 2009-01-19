From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH] gre: strict physical device binding
Date: Mon, 19 Jan 2009 12:50:05 +0200
Message-ID: <1232362205-10572-1-git-send-email-timo.teras@iki.fi>
Cc: Timo Teras <timo.teras@iki.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:15798 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754098AbZASKuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 05:50:11 -0500
Received: by nf-out-0910.google.com with SMTP id d3so401632nfc.21
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2009 02:50:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check the device on receive path and allow otherwise identical devices
as long as the physical device differs.

This is useful for NBMA tunnels, where you want to use different gre IP
for each public IP available via different physical devices.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---
 net/ipv4/ip_gre.c |  128 ++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 88 insertions(+), 40 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0101521..4a43739 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -164,67 +164,113 @@ static DEFINE_RWLOCK(ipgre_lock);
 
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
+	struct ip_tunnel *t, *sel[4] = { NULL, NULL, NULL, NULL };
 	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 	int dev_type = (gre_proto == htons(ETH_P_TEB)) ?
 		       ARPHRD_ETHER : ARPHRD_IPGRE;
+	int idx;
 
 	for (t = ign->tunnels_r_l[h0^h1]; t; t = t->next) {
-		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr) {
-			if (t->parms.i_key == key && t->dev->flags & IFF_UP) {
-				if (t->dev->type == dev_type)
-					return t;
-				if (t->dev->type == ARPHRD_IPGRE && !t2)
-					t2 = t;
-			}
-		}
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
+		idx = 0;
+		if (t->parms.link != link)
+			idx |= 1;
+		if (t->dev->type != dev_type)
+			idx |= 2;
+		if (idx == 0)
+			return t;
+		if (sel[idx] == NULL)
+			sel[idx] = t;
 	}
 
 	for (t = ign->tunnels_r[h0^h1]; t; t = t->next) {
-		if (remote == t->parms.iph.daddr) {
-			if (t->parms.i_key == key && t->dev->flags & IFF_UP) {
-				if (t->dev->type == dev_type)
-					return t;
-				if (t->dev->type == ARPHRD_IPGRE && !t2)
-					t2 = t;
-			}
-		}
+		if (remote != t->parms.iph.daddr ||
+		    key != t->parms.i_key ||
+		    !(t->dev->flags & IFF_UP))
+			continue;
+
+		if (t->dev->type != ARPHRD_IPGRE &&
+		    t->dev->type != dev_type)
+			continue;
+
+		idx = 0;
+		if (t->parms.link != link)
+			idx |= 1;
+		if (t->dev->type != dev_type)
+			idx |= 2;
+		if (idx == 0)
+			return t;
+		if (sel[idx] == NULL)
+			sel[idx] = t;
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
-		}
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
+		idx = 0;
+		if (t->parms.link != link)
+			idx |= 1;
+		if (t->dev->type != dev_type)
+			idx |= 2;
+		if (idx == 0)
+			return t;
+		if (sel[idx] == NULL)
+			sel[idx] = t;
 	}
 
 	for (t = ign->tunnels_wc[h1]; t; t = t->next) {
-		if (t->parms.i_key == key && t->dev->flags & IFF_UP) {
-			if (t->dev->type == dev_type)
-				return t;
-			if (t->dev->type == ARPHRD_IPGRE && !t2)
-				t2 = t;
-		}
+		if (t->parms.i_key != key ||
+		    !(t->dev->flags & IFF_UP))
+			continue;
+
+		if (t->dev->type != ARPHRD_IPGRE &&
+		    t->dev->type != dev_type)
+			continue;
+
+		idx = 0;
+		if (t->parms.link != link)
+			idx |= 1;
+		if (t->dev->type != dev_type)
+			idx |= 2;
+		if (idx == 0)
+			return t;
+		if (sel[idx] == NULL)
+			sel[idx] = t;
 	}
 
-	if (t2)
-		return t2;
+	for (idx = 1; idx < ARRAY_SIZE(sel); idx++)
+		if (sel[idx] != NULL)
+			return sel[idx];
 
-	if (ign->fb_tunnel_dev->flags&IFF_UP)
+	if (ign->fb_tunnel_dev->flags & IFF_UP)
 		return netdev_priv(ign->fb_tunnel_dev);
+
 	return NULL;
 }
 
@@ -284,6 +330,7 @@ static struct ip_tunnel *ipgre_tunnel_find(struct net *net,
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
 	__be32 key = parms->i_key;
+	int link = parms->link;
 	struct ip_tunnel *t, **tp;
 	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 
@@ -291,6 +338,7 @@ static struct ip_tunnel *ipgre_tunnel_find(struct net *net,
 		if (local == t->parms.iph.saddr &&
 		    remote == t->parms.iph.daddr &&
 		    key == t->parms.i_key &&
+		    link == t->parms.link &&
 		    type == t->dev->type)
 			break;
 
@@ -421,7 +469,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 	}
 
 	read_lock(&ipgre_lock);
-	t = ipgre_tunnel_lookup(dev_net(skb->dev), iph->daddr, iph->saddr,
+	t = ipgre_tunnel_lookup(skb->dev, iph->daddr, iph->saddr,
 				flags & GRE_KEY ?
 				*(((__be32 *)p) + (grehlen / 4) - 1) : 0,
 				p[1]);
@@ -518,7 +566,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 	gre_proto = *(__be16 *)(h + 2);
 
 	read_lock(&ipgre_lock);
-	if ((tunnel = ipgre_tunnel_lookup(dev_net(skb->dev),
+	if ((tunnel = ipgre_tunnel_lookup(skb->dev,
 					  iph->saddr, iph->daddr, key,
 					  gre_proto))) {
 		struct net_device_stats *stats = &tunnel->dev->stats;
-- 
1.5.6.3

