From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] gre: convert hash tables locking to RCU
Date: Fri, 23 Oct 2009 18:14:38 +0200
Message-ID: <4AE1D66E.2020605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54724 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017AbZJWQOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 12:14:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRE tunnels use one rwlock to protect their hash tables.

This locking scheme can be converted to RCU for free, since netdevice
already must wait for a RCU grace period at dismantle time.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_gre.c |   40 +++++++++++++++++++++++-----------------
 1 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 89ff9d5..40f0439 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -156,8 +156,13 @@ struct ipgre_net {
 #define tunnels_r	tunnels[2]
 #define tunnels_l	tunnels[1]
 #define tunnels_wc	tunnels[0]
+/*
+ * Locking : hash tables are protected by RCU and a spinlock
+ */
+static DEFINE_SPINLOCK(ipgre_lock);
 
-static DEFINE_RWLOCK(ipgre_lock);
+#define for_each_ip_tunnel_rcu(start) \
+	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
 
 /* Given src, dst and key, find appropriate for input tunnel. */
 
@@ -175,7 +180,7 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
 		       ARPHRD_ETHER : ARPHRD_IPGRE;
 	int score, cand_score = 4;
 
-	for (t = ign->tunnels_r_l[h0^h1]; t; t = t->next) {
+	for_each_ip_tunnel_rcu(ign->tunnels_r_l[h0 ^ h1]) {
 		if (local != t->parms.iph.saddr ||
 		    remote != t->parms.iph.daddr ||
 		    key != t->parms.i_key ||
@@ -200,7 +205,7 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
 		}
 	}
 
-	for (t = ign->tunnels_r[h0^h1]; t; t = t->next) {
+	for_each_ip_tunnel_rcu(ign->tunnels_r[h0 ^ h1]) {
 		if (remote != t->parms.iph.daddr ||
 		    key != t->parms.i_key ||
 		    !(t->dev->flags & IFF_UP))
@@ -224,7 +229,7 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
 		}
 	}
 
-	for (t = ign->tunnels_l[h1]; t; t = t->next) {
+	for_each_ip_tunnel_rcu(ign->tunnels_l[h1]) {
 		if ((local != t->parms.iph.saddr &&
 		     (local != t->parms.iph.daddr ||
 		      !ipv4_is_multicast(local))) ||
@@ -250,7 +255,7 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
 		}
 	}
 
-	for (t = ign->tunnels_wc[h1]; t; t = t->next) {
+	for_each_ip_tunnel_rcu(ign->tunnels_wc[h1]) {
 		if (t->parms.i_key != key ||
 		    !(t->dev->flags & IFF_UP))
 			continue;
@@ -276,8 +281,9 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
 	if (cand != NULL)
 		return cand;
 
-	if (ign->fb_tunnel_dev->flags & IFF_UP)
-		return netdev_priv(ign->fb_tunnel_dev);
+	dev = ign->fb_tunnel_dev;
+	if (dev->flags & IFF_UP)
+		return netdev_priv(dev);
 
 	return NULL;
 }
@@ -311,10 +317,10 @@ static void ipgre_tunnel_link(struct ipgre_net *ign, struct ip_tunnel *t)
 {
 	struct ip_tunnel **tp = ipgre_bucket(ign, t);
 
+	spin_lock_bh(&ipgre_lock);
 	t->next = *tp;
-	write_lock_bh(&ipgre_lock);
-	*tp = t;
-	write_unlock_bh(&ipgre_lock);
+	rcu_assign_pointer(*tp, t);
+	spin_unlock_bh(&ipgre_lock);
 }
 
 static void ipgre_tunnel_unlink(struct ipgre_net *ign, struct ip_tunnel *t)
@@ -323,9 +329,9 @@ static void ipgre_tunnel_unlink(struct ipgre_net *ign, struct ip_tunnel *t)
 
 	for (tp = ipgre_bucket(ign, t); *tp; tp = &(*tp)->next) {
 		if (t == *tp) {
-			write_lock_bh(&ipgre_lock);
+			spin_lock_bh(&ipgre_lock);
 			*tp = t->next;
-			write_unlock_bh(&ipgre_lock);
+			spin_unlock_bh(&ipgre_lock);
 			break;
 		}
 	}
@@ -476,7 +482,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 		break;
 	}
 
-	read_lock(&ipgre_lock);
+	rcu_read_lock();
 	t = ipgre_tunnel_lookup(skb->dev, iph->daddr, iph->saddr,
 				flags & GRE_KEY ?
 				*(((__be32 *)p) + (grehlen / 4) - 1) : 0,
@@ -494,7 +500,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 		t->err_count = 1;
 	t->err_time = jiffies;
 out:
-	read_unlock(&ipgre_lock);
+	rcu_read_unlock();
 	return;
 }
 
@@ -573,7 +579,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 
 	gre_proto = *(__be16 *)(h + 2);
 
-	read_lock(&ipgre_lock);
+	rcu_read_lock();
 	if ((tunnel = ipgre_tunnel_lookup(skb->dev,
 					  iph->saddr, iph->daddr, key,
 					  gre_proto))) {
@@ -647,13 +653,13 @@ static int ipgre_rcv(struct sk_buff *skb)
 		ipgre_ecn_decapsulate(iph, skb);
 
 		netif_rx(skb);
-		read_unlock(&ipgre_lock);
+		rcu_read_unlock();
 		return(0);
 	}
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 
 drop:
-	read_unlock(&ipgre_lock);
+	rcu_read_unlock();
 drop_nolock:
 	kfree_skb(skb);
 	return(0);
