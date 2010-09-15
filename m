From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 3/3] gre: get rid of ipgre_lock
Date: Wed, 15 Sep 2010 23:07:53 +0200
Message-ID: <1284584873.2462.71.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62807 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754990Ab0IOVJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 17:09:26 -0400
Received: by wwd20 with SMTP id 20so19295wwd.1
        for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 14:08:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As RTNL is held while doing tunnels inserts and deletes, we can remove
ipgre_lock spinlock. My initial RCU conversion was conservative and
converted the rwlock to spinlock, with no RTNL requirement.

Use appropriate rcu annotations and modern lockdep checks as well.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Tested with CONFIG_PROVE_RCU=y

 net/ipv4/ip_gre.c |   61 +++++++++++++++++++++++---------------------
 1 files changed, 32 insertions(+), 29 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 8517689..fc20e68 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -129,7 +129,7 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev);
 
 static int ipgre_net_id __read_mostly;
 struct ipgre_net {
-	struct ip_tunnel *tunnels[4][HASH_SIZE];
+	struct ip_tunnel __rcu *tunnels[4][HASH_SIZE];
 
 	struct net_device *fb_tunnel_dev;
 };
@@ -159,9 +159,8 @@ struct ipgre_net {
 #define tunnels_l	tunnels[1]
 #define tunnels_wc	tunnels[0]
 /*
- * Locking : hash tables are protected by RCU and a spinlock
+ * Locking : hash tables are protected by RCU and RTNL
  */
-static DEFINE_SPINLOCK(ipgre_lock);
 
 #define for_each_ip_tunnel_rcu(start) \
 	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
@@ -174,8 +173,8 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
 {
 	struct net *net = dev_net(dev);
 	int link = dev->ifindex;
-	unsigned h0 = HASH(remote);
-	unsigned h1 = HASH(key);
+	unsigned int h0 = HASH(remote);
+	unsigned int h1 = HASH(key);
 	struct ip_tunnel *t, *cand = NULL;
 	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 	int dev_type = (gre_proto == htons(ETH_P_TEB)) ?
@@ -290,13 +289,13 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
 	return NULL;
 }
 
-static struct ip_tunnel **__ipgre_bucket(struct ipgre_net *ign,
+static struct ip_tunnel __rcu **__ipgre_bucket(struct ipgre_net *ign,
 		struct ip_tunnel_parm *parms)
 {
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
 	__be32 key = parms->i_key;
-	unsigned h = HASH(key);
+	unsigned int h = HASH(key);
 	int prio = 0;
 
 	if (local)
@@ -309,7 +308,7 @@ static struct ip_tunnel **__ipgre_bucket(struct ipgre_net *ign,
 	return &ign->tunnels[prio][h];
 }
 
-static inline struct ip_tunnel **ipgre_bucket(struct ipgre_net *ign,
+static inline struct ip_tunnel __rcu **ipgre_bucket(struct ipgre_net *ign,
 		struct ip_tunnel *t)
 {
 	return __ipgre_bucket(ign, &t->parms);
@@ -317,23 +316,22 @@ static inline struct ip_tunnel **ipgre_bucket(struct ipgre_net *ign,
 
 static void ipgre_tunnel_link(struct ipgre_net *ign, struct ip_tunnel *t)
 {
-	struct ip_tunnel **tp = ipgre_bucket(ign, t);
+	struct ip_tunnel __rcu **tp = ipgre_bucket(ign, t);
 
-	spin_lock_bh(&ipgre_lock);
-	t->next = *tp;
+	rcu_assign_pointer(t->next, rtnl_dereference(*tp));
 	rcu_assign_pointer(*tp, t);
-	spin_unlock_bh(&ipgre_lock);
 }
 
 static void ipgre_tunnel_unlink(struct ipgre_net *ign, struct ip_tunnel *t)
 {
-	struct ip_tunnel **tp;
-
-	for (tp = ipgre_bucket(ign, t); *tp; tp = &(*tp)->next) {
-		if (t == *tp) {
-			spin_lock_bh(&ipgre_lock);
-			*tp = t->next;
-			spin_unlock_bh(&ipgre_lock);
+	struct ip_tunnel __rcu **tp;
+	struct ip_tunnel *iter;
+
+	for (tp = ipgre_bucket(ign, t);
+	     (iter = rtnl_dereference(*tp)) != NULL;
+	     tp = &iter->next) {
+		if (t == iter) {
+			rcu_assign_pointer(*tp, t->next);
 			break;
 		}
 	}
@@ -347,10 +345,13 @@ static struct ip_tunnel *ipgre_tunnel_find(struct net *net,
 	__be32 local = parms->iph.saddr;
 	__be32 key = parms->i_key;
 	int link = parms->link;
-	struct ip_tunnel *t, **tp;
+	struct ip_tunnel *t;
+	struct ip_tunnel __rcu **tp;
 	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 
-	for (tp = __ipgre_bucket(ign, parms); (t = *tp) != NULL; tp = &t->next)
+	for (tp = __ipgre_bucket(ign, parms);
+	     (t = rtnl_dereference(*tp)) != NULL;
+	     tp = &t->next)
 		if (local == t->parms.iph.saddr &&
 		    remote == t->parms.iph.daddr &&
 		    key == t->parms.i_key &&
@@ -361,7 +362,7 @@ static struct ip_tunnel *ipgre_tunnel_find(struct net *net,
 	return t;
 }
 
-static struct ip_tunnel * ipgre_tunnel_locate(struct net *net,
+static struct ip_tunnel *ipgre_tunnel_locate(struct net *net,
 		struct ip_tunnel_parm *parms, int create)
 {
 	struct ip_tunnel *t, *nt;
@@ -669,7 +670,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	u8     tos;
 	__be16 df;
 	struct rtable *rt;     			/* Route to the other host */
-	struct net_device *tdev;			/* Device to other host */
+	struct net_device *tdev;		/* Device to other host */
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
 	int    gre_hlen;
@@ -1013,7 +1014,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 					break;
 				}
 			} else {
-				unsigned nflags = 0;
+				unsigned int nflags = 0;
 
 				t = netdev_priv(dev);
 
@@ -1126,7 +1127,7 @@ static int ipgre_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 
 static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type,
-			const void *daddr, const void *saddr, unsigned len)
+			const void *daddr, const void *saddr, unsigned int len)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 	struct iphdr *iph = (struct iphdr *)skb_push(skb, t->hlen);
@@ -1275,7 +1276,7 @@ static void ipgre_fb_tunnel_init(struct net_device *dev)
 	tunnel->hlen		= sizeof(struct iphdr) + 4;
 
 	dev_hold(dev);
-	ign->tunnels_wc[0]	= tunnel;
+	rcu_assign_pointer(ign->tunnels_wc[0], tunnel);
 }
 
 
@@ -1291,11 +1292,13 @@ static void ipgre_destroy_tunnels(struct ipgre_net *ign, struct list_head *head)
 	for (prio = 0; prio < 4; prio++) {
 		int h;
 		for (h = 0; h < HASH_SIZE; h++) {
-			struct ip_tunnel *t = ign->tunnels[prio][h];
+			struct ip_tunnel *t;
+
+			t = rtnl_dereference(ign->tunnels[prio][h]);
 
 			while (t != NULL) {
 				unregister_netdevice_queue(t->dev, head);
-				t = t->next;
+				t = rtnl_dereference(t->next);
 			}
 		}
 	}
@@ -1522,7 +1525,7 @@ static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
 		t = nt;
 
 		if (dev->type != ARPHRD_ETHER) {
-			unsigned nflags = 0;
+			unsigned int nflags = 0;
 
 			if (ipv4_is_multicast(p.iph.daddr))
 				nflags = IFF_BROADCAST;


