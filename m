From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ip6tnl: get rid of ip6_tnl_lock
Date: Thu, 16 Sep 2010 08:25:34 +0200
Message-ID: <1284618334.2462.94.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65496 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780Ab0IPGc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 02:32:29 -0400
Received: by wwd20 with SMTP id 20so23227wwd.1
        for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 23:32:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As RTNL is held while doing tunnels inserts and deletes, we can remove
ip6_tnl_lock spinlock. My initial RCU conversion was conservative and
converted the rwlock to spinlock, with no RTNL requirement.

Use appropriate rcu annotations and modern lockdep checks as well.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/ip6_tunnel.c |   58 +++++++++++++++++++---------------------
 1 files changed, 28 insertions(+), 30 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 29f99dd..9289cec 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -83,15 +83,14 @@ struct ip6_tnl_net {
 	/* the IPv6 tunnel fallback device */
 	struct net_device *fb_tnl_dev;
 	/* lists for storing tunnels in use */
-	struct ip6_tnl *tnls_r_l[HASH_SIZE];
-	struct ip6_tnl *tnls_wc[1];
-	struct ip6_tnl **tnls[2];
+	struct ip6_tnl __rcu *tnls_r_l[HASH_SIZE];
+	struct ip6_tnl __rcu *tnls_wc[1];
+	struct ip6_tnl __rcu **tnls[2];
 };
 
 /*
- * Locking : hash tables are protected by RCU and a spinlock
+ * Locking : hash tables are protected by RCU and RTNL
  */
-static DEFINE_SPINLOCK(ip6_tnl_lock);
 
 static inline struct dst_entry *ip6_tnl_dst_check(struct ip6_tnl *t)
 {
@@ -138,8 +137,8 @@ static inline void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst)
 static struct ip6_tnl *
 ip6_tnl_lookup(struct net *net, struct in6_addr *remote, struct in6_addr *local)
 {
-	unsigned h0 = HASH(remote);
-	unsigned h1 = HASH(local);
+	unsigned int h0 = HASH(remote);
+	unsigned int h1 = HASH(local);
 	struct ip6_tnl *t;
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
@@ -167,7 +166,7 @@ ip6_tnl_lookup(struct net *net, struct in6_addr *remote, struct in6_addr *local)
  * Return: head of IPv6 tunnel list
  **/
 
-static struct ip6_tnl **
+static struct ip6_tnl __rcu **
 ip6_tnl_bucket(struct ip6_tnl_net *ip6n, struct ip6_tnl_parm *p)
 {
 	struct in6_addr *remote = &p->raddr;
@@ -190,12 +189,10 @@ ip6_tnl_bucket(struct ip6_tnl_net *ip6n, struct ip6_tnl_parm *p)
 static void
 ip6_tnl_link(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
 {
-	struct ip6_tnl **tp = ip6_tnl_bucket(ip6n, &t->parms);
+	struct ip6_tnl __rcu **tp = ip6_tnl_bucket(ip6n, &t->parms);
 
-	spin_lock_bh(&ip6_tnl_lock);
-	t->next = *tp;
+	rcu_assign_pointer(t->next , rtnl_dereference(*tp));
 	rcu_assign_pointer(*tp, t);
-	spin_unlock_bh(&ip6_tnl_lock);
 }
 
 /**
@@ -206,13 +203,14 @@ ip6_tnl_link(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
 static void
 ip6_tnl_unlink(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
 {
-	struct ip6_tnl **tp;
-
-	for (tp = ip6_tnl_bucket(ip6n, &t->parms); *tp; tp = &(*tp)->next) {
-		if (t == *tp) {
-			spin_lock_bh(&ip6_tnl_lock);
-			*tp = t->next;
-			spin_unlock_bh(&ip6_tnl_lock);
+	struct ip6_tnl __rcu **tp;
+	struct ip6_tnl *iter;
+
+	for (tp = ip6_tnl_bucket(ip6n, &t->parms);
+	     (iter = rtnl_dereference(*tp)) != NULL;
+	     tp = &iter->next) {
+		if (t == iter) {
+			rcu_assign_pointer(*tp, t->next);
 			break;
 		}
 	}
@@ -290,10 +288,13 @@ static struct ip6_tnl *ip6_tnl_locate(struct net *net,
 {
 	struct in6_addr *remote = &p->raddr;
 	struct in6_addr *local = &p->laddr;
+	struct ip6_tnl __rcu **tp;
 	struct ip6_tnl *t;
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
-	for (t = *ip6_tnl_bucket(ip6n, p); t; t = t->next) {
+	for (tp = ip6_tnl_bucket(ip6n, p);
+	     (t = rtnl_dereference(*tp)) != NULL;
+	     tp = &t->next) {
 		if (ipv6_addr_equal(local, &t->parms.laddr) &&
 		    ipv6_addr_equal(remote, &t->parms.raddr))
 			return t;
@@ -318,13 +319,10 @@ ip6_tnl_dev_uninit(struct net_device *dev)
 	struct net *net = dev_net(dev);
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
-	if (dev == ip6n->fb_tnl_dev) {
-		spin_lock_bh(&ip6_tnl_lock);
-		ip6n->tnls_wc[0] = NULL;
-		spin_unlock_bh(&ip6_tnl_lock);
-	} else {
+	if (dev == ip6n->fb_tnl_dev)
+		rcu_assign_pointer(ip6n->tnls_wc[0], NULL);
+	else
 		ip6_tnl_unlink(ip6n, t);
-	}
 	ip6_tnl_dst_reset(t);
 	dev_put(dev);
 }
@@ -1369,7 +1367,7 @@ static void __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
 	ip6_tnl_dev_init_gen(dev);
 	t->parms.proto = IPPROTO_IPV6;
 	dev_hold(dev);
-	ip6n->tnls_wc[0] = t;
+	rcu_assign_pointer(ip6n->tnls_wc[0], t);
 }
 
 static struct xfrm6_tunnel ip4ip6_handler __read_mostly = {
@@ -1391,14 +1389,14 @@ static void __net_exit ip6_tnl_destroy_tunnels(struct ip6_tnl_net *ip6n)
 	LIST_HEAD(list);
 
 	for (h = 0; h < HASH_SIZE; h++) {
-		t = ip6n->tnls_r_l[h];
+		t = rtnl_dereference(ip6n->tnls_r_l[h]);
 		while (t != NULL) {
 			unregister_netdevice_queue(t->dev, &list);
-			t = t->next;
+			t = rtnl_dereference(t->next);
 		}
 	}
 
-	t = ip6n->tnls_wc[0];
+	t = rtnl_dereference(ip6n->tnls_wc[0]);
 	unregister_netdevice_queue(t->dev, &list);
 	unregister_netdevice_many(&list);
 }


