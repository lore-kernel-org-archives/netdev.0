From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/2 net-next-2.6] ipv6 sit: RCU conversion phase II
Date: Sat, 24 Oct 2009 05:52:14 +0200
Message-ID: <4AE279EE.8090007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Yoshifuji Hideaki <yoshfuji@linux-ipv6.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42361 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbZJXDwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 23:52:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIT tunnels use one rwlock to protect their hash tables.

This locking scheme can be converted to RCU for free, since netdevice
already must wait for a RCU grace period at dismantle time.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/sit.c |   45 +++++++++++++++++++++++++++------------------
 1 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 8cdcc2a..b6b1626 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -77,8 +77,17 @@ struct sit_net {
 	struct net_device *fb_tunnel_dev;
 };
 
-static DEFINE_RWLOCK(ipip6_lock);
+/*
+ * Locking : hash tables are protected by RCU and a spinlock
+ */
+static DEFINE_SPINLOCK(ipip6_lock);
+
+#define for_each_ip_tunnel_rcu(start) \
+	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
 
+/*
+ * Must be invoked with rcu_read_lock
+ */
 static struct ip_tunnel * ipip6_tunnel_lookup(struct net *net,
 		struct net_device *dev, __be32 remote, __be32 local)
 {
@@ -87,26 +96,26 @@ static struct ip_tunnel * ipip6_tunnel_lookup(struct net *net,
 	struct ip_tunnel *t;
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
-	for (t = sitn->tunnels_r_l[h0^h1]; t; t = t->next) {
+	for_each_ip_tunnel_rcu(sitn->tunnels_r_l[h0 ^ h1]) {
 		if (local == t->parms.iph.saddr &&
 		    remote == t->parms.iph.daddr &&
 		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
-	for (t = sitn->tunnels_r[h0]; t; t = t->next) {
+	for_each_ip_tunnel_rcu(sitn->tunnels_r[h0]) {
 		if (remote == t->parms.iph.daddr &&
 		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
-	for (t = sitn->tunnels_l[h1]; t; t = t->next) {
+	for_each_ip_tunnel_rcu(sitn->tunnels_l[h1]) {
 		if (local == t->parms.iph.saddr &&
 		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
-	t = sitn->tunnels_wc[0];
+	t = rcu_dereference(sitn->tunnels_wc[0]);
 	if ((t != NULL) && (t->dev->flags & IFF_UP))
 		return t;
 	return NULL;
@@ -143,9 +152,9 @@ static void ipip6_tunnel_unlink(struct sit_net *sitn, struct ip_tunnel *t)
 
 	for (tp = ipip6_bucket(sitn, t); *tp; tp = &(*tp)->next) {
 		if (t == *tp) {
-			write_lock_bh(&ipip6_lock);
+			spin_lock_bh(&ipip6_lock);
 			*tp = t->next;
-			write_unlock_bh(&ipip6_lock);
+			spin_unlock_bh(&ipip6_lock);
 			break;
 		}
 	}
@@ -155,10 +164,10 @@ static void ipip6_tunnel_link(struct sit_net *sitn, struct ip_tunnel *t)
 {
 	struct ip_tunnel **tp = ipip6_bucket(sitn, t);
 
+	spin_lock_bh(&ipip6_lock);
 	t->next = *tp;
-	write_lock_bh(&ipip6_lock);
-	*tp = t;
-	write_unlock_bh(&ipip6_lock);
+	rcu_assign_pointer(*tp, t);
+	spin_unlock_bh(&ipip6_lock);
 }
 
 static void ipip6_tunnel_clone_6rd(struct net_device *dev, struct sit_net *sitn)
@@ -447,9 +456,9 @@ static void ipip6_tunnel_uninit(struct net_device *dev)
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
 	if (dev == sitn->fb_tunnel_dev) {
-		write_lock_bh(&ipip6_lock);
+		spin_lock_bh(&ipip6_lock);
 		sitn->tunnels_wc[0] = NULL;
-		write_unlock_bh(&ipip6_lock);
+		spin_unlock_bh(&ipip6_lock);
 		dev_put(dev);
 	} else {
 		ipip6_tunnel_unlink(sitn, netdev_priv(dev));
@@ -502,7 +511,7 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 
 	err = -ENOENT;
 
-	read_lock(&ipip6_lock);
+	rcu_read_lock();
 	t = ipip6_tunnel_lookup(dev_net(skb->dev),
 				skb->dev,
 				iph->daddr,
@@ -520,7 +529,7 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 		t->err_count = 1;
 	t->err_time = jiffies;
 out:
-	read_unlock(&ipip6_lock);
+	rcu_read_unlock();
 	return err;
 }
 
@@ -540,7 +549,7 @@ static int ipip6_rcv(struct sk_buff *skb)
 
 	iph = ip_hdr(skb);
 
-	read_lock(&ipip6_lock);
+	rcu_read_lock();
 	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
 				     iph->saddr, iph->daddr);
 	if (tunnel != NULL) {
@@ -554,7 +563,7 @@ static int ipip6_rcv(struct sk_buff *skb)
 		if ((tunnel->dev->priv_flags & IFF_ISATAP) &&
 		    !isatap_chksrc(skb, iph, tunnel)) {
 			tunnel->dev->stats.rx_errors++;
-			read_unlock(&ipip6_lock);
+			rcu_read_unlock();
 			kfree_skb(skb);
 			return 0;
 		}
@@ -565,12 +574,12 @@ static int ipip6_rcv(struct sk_buff *skb)
 		nf_reset(skb);
 		ipip6_ecn_decapsulate(iph, skb);
 		netif_rx(skb);
-		read_unlock(&ipip6_lock);
+		rcu_read_unlock();
 		return 0;
 	}
 
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
-	read_unlock(&ipip6_lock);
+	rcu_read_unlock();
 out:
 	kfree_skb(skb);
 	return 0;
