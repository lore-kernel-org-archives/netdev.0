From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ip6tnl: convert hash tables locking to RCU
Date: Fri, 23 Oct 2009 18:34:34 +0200
Message-ID: <4AE1DB1A.3070709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35327 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444AbZJWQed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 12:34:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_tunnels use one rwlock to protect their hash tables.

This locking scheme can be converted to RCU for free, since netdevice
already must wait for a RCU grace period at dismantle time.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/ip6_tunnel.c |   44 ++++++++++++++++++++++------------------
 1 files changed, 25 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index c595bbe..670c291 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -88,8 +88,10 @@ struct ip6_tnl_net {
 	struct ip6_tnl **tnls[2];
 };
 
-/* lock for the tunnel lists */
-static DEFINE_RWLOCK(ip6_tnl_lock);
+/*
+ * Locking : hash tables are protected by RCU and a spinlock
+ */
+static DEFINE_SPINLOCK(ip6_tnl_lock);
 
 static inline struct dst_entry *ip6_tnl_dst_check(struct ip6_tnl *t)
 {
@@ -130,6 +132,9 @@ static inline void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst)
  *   else %NULL
  **/
 
+#define for_each_ip6_tunnel_rcu(start) \
+	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
+
 static struct ip6_tnl *
 ip6_tnl_lookup(struct net *net, struct in6_addr *remote, struct in6_addr *local)
 {
@@ -138,13 +143,14 @@ ip6_tnl_lookup(struct net *net, struct in6_addr *remote, struct in6_addr *local)
 	struct ip6_tnl *t;
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
-	for (t = ip6n->tnls_r_l[h0 ^ h1]; t; t = t->next) {
+	for_each_ip6_tunnel_rcu(ip6n->tnls_r_l[h0 ^ h1]) {
 		if (ipv6_addr_equal(local, &t->parms.laddr) &&
 		    ipv6_addr_equal(remote, &t->parms.raddr) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
-	if ((t = ip6n->tnls_wc[0]) != NULL && (t->dev->flags & IFF_UP))
+	t = rcu_dereference(ip6n->tnls_wc[0]);
+	if (t && (t->dev->flags & IFF_UP))
 		return t;
 
 	return NULL;
@@ -186,10 +192,10 @@ ip6_tnl_link(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
 {
 	struct ip6_tnl **tp = ip6_tnl_bucket(ip6n, &t->parms);
 
+	spin_lock_bh(&ip6_tnl_lock);
 	t->next = *tp;
-	write_lock_bh(&ip6_tnl_lock);
-	*tp = t;
-	write_unlock_bh(&ip6_tnl_lock);
+	rcu_assign_pointer(*tp, t);
+	spin_unlock_bh(&ip6_tnl_lock);
 }
 
 /**
@@ -204,9 +210,9 @@ ip6_tnl_unlink(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
 
 	for (tp = ip6_tnl_bucket(ip6n, &t->parms); *tp; tp = &(*tp)->next) {
 		if (t == *tp) {
-			write_lock_bh(&ip6_tnl_lock);
+			spin_lock_bh(&ip6_tnl_lock);
 			*tp = t->next;
-			write_unlock_bh(&ip6_tnl_lock);
+			spin_unlock_bh(&ip6_tnl_lock);
 			break;
 		}
 	}
@@ -313,9 +319,9 @@ ip6_tnl_dev_uninit(struct net_device *dev)
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
 	if (dev == ip6n->fb_tnl_dev) {
-		write_lock_bh(&ip6_tnl_lock);
+		spin_lock_bh(&ip6_tnl_lock);
 		ip6n->tnls_wc[0] = NULL;
-		write_unlock_bh(&ip6_tnl_lock);
+		spin_unlock_bh(&ip6_tnl_lock);
 	} else {
 		ip6_tnl_unlink(ip6n, t);
 	}
@@ -409,7 +415,7 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 	   in trouble since we might need the source address for further
 	   processing of the error. */
 
-	read_lock(&ip6_tnl_lock);
+	rcu_read_lock();
 	if ((t = ip6_tnl_lookup(dev_net(skb->dev), &ipv6h->daddr,
 					&ipv6h->saddr)) == NULL)
 		goto out;
@@ -482,7 +488,7 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 	*msg = rel_msg;
 
 out:
-	read_unlock(&ip6_tnl_lock);
+	rcu_read_unlock();
 	return err;
 }
 
@@ -693,23 +699,23 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 	struct ip6_tnl *t;
 	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 
-	read_lock(&ip6_tnl_lock);
+	rcu_read_lock();
 
 	if ((t = ip6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr,
 					&ipv6h->daddr)) != NULL) {
 		if (t->parms.proto != ipproto && t->parms.proto != 0) {
-			read_unlock(&ip6_tnl_lock);
+			rcu_read_unlock();
 			goto discard;
 		}
 
 		if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-			read_unlock(&ip6_tnl_lock);
+			rcu_read_unlock();
 			goto discard;
 		}
 
 		if (!ip6_tnl_rcv_ctl(t)) {
 			t->dev->stats.rx_dropped++;
-			read_unlock(&ip6_tnl_lock);
+			rcu_read_unlock();
 			goto discard;
 		}
 		secpath_reset(skb);
@@ -727,10 +733,10 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 		t->dev->stats.rx_packets++;
 		t->dev->stats.rx_bytes += skb->len;
 		netif_rx(skb);
-		read_unlock(&ip6_tnl_lock);
+		rcu_read_unlock();
 		return 0;
 	}
-	read_unlock(&ip6_tnl_lock);
+	rcu_read_unlock();
 	return 1;
 
 discard:
