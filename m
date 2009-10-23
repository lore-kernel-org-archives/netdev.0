From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipip: convert hash tables locking to RCU
Date: Fri, 23 Oct 2009 17:42:02 +0200
Message-ID: <4AE1CECA.1060503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43752 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbZJWPmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 11:42:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPIP tunnels use one rwlock to protect their hash tables.

This locking scheme can be converted to RCU for free, since netdevice
already must wait for a RCU grace period at dismantle time.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ipip.c |   49 ++++++++++++++++++++++++++--------------------
 1 files changed, 28 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 6a55392..3bd6998 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -134,7 +134,13 @@ static void ipip_fb_tunnel_init(struct net_device *dev);
 static void ipip_tunnel_init(struct net_device *dev);
 static void ipip_tunnel_setup(struct net_device *dev);
 
-static DEFINE_RWLOCK(ipip_lock);
+/*
+ * Locking : hash tables are protected by RCU and a spinlock
+ */
+static DEFINE_SPINLOCK(ipip_lock);
+
+#define for_each_ip_tunnel_rcu(start) \
+	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
 
 static struct ip_tunnel * ipip_tunnel_lookup(struct net *net,
 		__be32 remote, __be32 local)
@@ -144,20 +150,21 @@ static struct ip_tunnel * ipip_tunnel_lookup(struct net *net,
 	struct ip_tunnel *t;
 	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 
-	for (t = ipn->tunnels_r_l[h0^h1]; t; t = t->next) {
+	for_each_ip_tunnel_rcu(ipn->tunnels_r_l[h0 ^ h1])
 		if (local == t->parms.iph.saddr &&
 		    remote == t->parms.iph.daddr && (t->dev->flags&IFF_UP))
 			return t;
-	}
-	for (t = ipn->tunnels_r[h0]; t; t = t->next) {
+
+	for_each_ip_tunnel_rcu(ipn->tunnels_r[h0])
 		if (remote == t->parms.iph.daddr && (t->dev->flags&IFF_UP))
 			return t;
-	}
-	for (t = ipn->tunnels_l[h1]; t; t = t->next) {
+
+	for_each_ip_tunnel_rcu(ipn->tunnels_l[h1])
 		if (local == t->parms.iph.saddr && (t->dev->flags&IFF_UP))
 			return t;
-	}
-	if ((t = ipn->tunnels_wc[0]) != NULL && (t->dev->flags&IFF_UP))
+
+	t = rcu_dereference(ipn->tunnels_wc[0]);
+	if (t && (t->dev->flags&IFF_UP))
 		return t;
 	return NULL;
 }
@@ -193,9 +200,9 @@ static void ipip_tunnel_unlink(struct ipip_net *ipn, struct ip_tunnel *t)
 
 	for (tp = ipip_bucket(ipn, t); *tp; tp = &(*tp)->next) {
 		if (t == *tp) {
-			write_lock_bh(&ipip_lock);
+			spin_lock_bh(&ipip_lock);
 			*tp = t->next;
-			write_unlock_bh(&ipip_lock);
+			spin_unlock_bh(&ipip_lock);
 			break;
 		}
 	}
@@ -205,10 +212,10 @@ static void ipip_tunnel_link(struct ipip_net *ipn, struct ip_tunnel *t)
 {
 	struct ip_tunnel **tp = ipip_bucket(ipn, t);
 
+	spin_lock_bh(&ipip_lock);
 	t->next = *tp;
-	write_lock_bh(&ipip_lock);
-	*tp = t;
-	write_unlock_bh(&ipip_lock);
+	rcu_assign_pointer(*tp, t);
+	spin_unlock_bh(&ipip_lock);
 }
 
 static struct ip_tunnel * ipip_tunnel_locate(struct net *net,
@@ -267,9 +274,9 @@ static void ipip_tunnel_uninit(struct net_device *dev)
 	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 
 	if (dev == ipn->fb_tunnel_dev) {
-		write_lock_bh(&ipip_lock);
+		spin_lock_bh(&ipip_lock);
 		ipn->tunnels_wc[0] = NULL;
-		write_unlock_bh(&ipip_lock);
+		spin_unlock_bh(&ipip_lock);
 	} else
 		ipip_tunnel_unlink(ipn, netdev_priv(dev));
 	dev_put(dev);
@@ -318,7 +325,7 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 
 	err = -ENOENT;
 
-	read_lock(&ipip_lock);
+	rcu_read_lock();
 	t = ipip_tunnel_lookup(dev_net(skb->dev), iph->daddr, iph->saddr);
 	if (t == NULL || t->parms.iph.daddr == 0)
 		goto out;
@@ -333,7 +340,7 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 		t->err_count = 1;
 	t->err_time = jiffies;
 out:
-	read_unlock(&ipip_lock);
+	rcu_read_unlock();
 	return err;
 }
 
@@ -351,11 +358,11 @@ static int ipip_rcv(struct sk_buff *skb)
 	struct ip_tunnel *tunnel;
 	const struct iphdr *iph = ip_hdr(skb);
 
-	read_lock(&ipip_lock);
+	rcu_read_lock();
 	if ((tunnel = ipip_tunnel_lookup(dev_net(skb->dev),
 					iph->saddr, iph->daddr)) != NULL) {
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-			read_unlock(&ipip_lock);
+			rcu_read_unlock();
 			kfree_skb(skb);
 			return 0;
 		}
@@ -374,10 +381,10 @@ static int ipip_rcv(struct sk_buff *skb)
 		nf_reset(skb);
 		ipip_ecn_decapsulate(iph, skb);
 		netif_rx(skb);
-		read_unlock(&ipip_lock);
+		rcu_read_unlock();
 		return 0;
 	}
-	read_unlock(&ipip_lock);
+	rcu_read_unlock();
 
 	return -1;
 }
