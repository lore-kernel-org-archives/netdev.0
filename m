From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 4/4] sit: get rid of ipip6_lock
Date: Wed, 15 Sep 2010 23:35:10 +0200
Message-ID: <1284586510.2462.77.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60880 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861Ab0IOVfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 17:35:15 -0400
Received: by wyf22 with SMTP id 22so709086wyf.19
        for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 14:35:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As RTNL is held while doing tunnels inserts and deletes, we can remove
ipip6_lock spinlock. My initial RCU conversion was conservative and
converted the rwlock to spinlock, with no RTNL requirement.

Use appropriate rcu annotations and modern lockdep checks as well.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/sit.c |   64 ++++++++++++++++++++++-------------------------
 1 files changed, 31 insertions(+), 33 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 86618eb..6822481 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -68,19 +68,18 @@ static void ipip6_tunnel_setup(struct net_device *dev);
 
 static int sit_net_id __read_mostly;
 struct sit_net {
-	struct ip_tunnel *tunnels_r_l[HASH_SIZE];
-	struct ip_tunnel *tunnels_r[HASH_SIZE];
-	struct ip_tunnel *tunnels_l[HASH_SIZE];
-	struct ip_tunnel *tunnels_wc[1];
-	struct ip_tunnel **tunnels[4];
+	struct ip_tunnel __rcu *tunnels_r_l[HASH_SIZE];
+	struct ip_tunnel __rcu *tunnels_r[HASH_SIZE];
+	struct ip_tunnel __rcu *tunnels_l[HASH_SIZE];
+	struct ip_tunnel __rcu *tunnels_wc[1];
+	struct ip_tunnel __rcu **tunnels[4];
 
 	struct net_device *fb_tunnel_dev;
 };
 
 /*
- * Locking : hash tables are protected by RCU and a spinlock
+ * Locking : hash tables are protected by RCU and RTNL
  */
-static DEFINE_SPINLOCK(ipip6_lock);
 
 #define for_each_ip_tunnel_rcu(start) \
 	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
@@ -91,8 +90,8 @@ static DEFINE_SPINLOCK(ipip6_lock);
 static struct ip_tunnel * ipip6_tunnel_lookup(struct net *net,
 		struct net_device *dev, __be32 remote, __be32 local)
 {
-	unsigned h0 = HASH(remote);
-	unsigned h1 = HASH(local);
+	unsigned int h0 = HASH(remote);
+	unsigned int h1 = HASH(local);
 	struct ip_tunnel *t;
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
@@ -121,12 +120,12 @@ static struct ip_tunnel * ipip6_tunnel_lookup(struct net *net,
 	return NULL;
 }
 
-static struct ip_tunnel **__ipip6_bucket(struct sit_net *sitn,
+static struct ip_tunnel __rcu **__ipip6_bucket(struct sit_net *sitn,
 		struct ip_tunnel_parm *parms)
 {
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
-	unsigned h = 0;
+	unsigned int h = 0;
 	int prio = 0;
 
 	if (remote) {
@@ -140,7 +139,7 @@ static struct ip_tunnel **__ipip6_bucket(struct sit_net *sitn,
 	return &sitn->tunnels[prio][h];
 }
 
-static inline struct ip_tunnel **ipip6_bucket(struct sit_net *sitn,
+static inline struct ip_tunnel __rcu **ipip6_bucket(struct sit_net *sitn,
 		struct ip_tunnel *t)
 {
 	return __ipip6_bucket(sitn, &t->parms);
@@ -148,13 +147,14 @@ static inline struct ip_tunnel **ipip6_bucket(struct sit_net *sitn,
 
 static void ipip6_tunnel_unlink(struct sit_net *sitn, struct ip_tunnel *t)
 {
-	struct ip_tunnel **tp;
-
-	for (tp = ipip6_bucket(sitn, t); *tp; tp = &(*tp)->next) {
-		if (t == *tp) {
-			spin_lock_bh(&ipip6_lock);
-			*tp = t->next;
-			spin_unlock_bh(&ipip6_lock);
+	struct ip_tunnel __rcu **tp;
+	struct ip_tunnel *iter;
+
+	for (tp = ipip6_bucket(sitn, t);
+	     (iter = rtnl_dereference(*tp)) != NULL;
+	     tp = &iter->next) {
+		if (t == iter) {
+			rcu_assign_pointer(*tp, t->next);
 			break;
 		}
 	}
@@ -162,12 +162,10 @@ static void ipip6_tunnel_unlink(struct sit_net *sitn, struct ip_tunnel *t)
 
 static void ipip6_tunnel_link(struct sit_net *sitn, struct ip_tunnel *t)
 {
-	struct ip_tunnel **tp = ipip6_bucket(sitn, t);
+	struct ip_tunnel __rcu **tp = ipip6_bucket(sitn, t);
 
-	spin_lock_bh(&ipip6_lock);
-	t->next = *tp;
+	rcu_assign_pointer(t->next, rtnl_dereference(*tp));
 	rcu_assign_pointer(*tp, t);
-	spin_unlock_bh(&ipip6_lock);
 }
 
 static void ipip6_tunnel_clone_6rd(struct net_device *dev, struct sit_net *sitn)
@@ -187,17 +185,20 @@ static void ipip6_tunnel_clone_6rd(struct net_device *dev, struct sit_net *sitn)
 #endif
 }
 
-static struct ip_tunnel * ipip6_tunnel_locate(struct net *net,
+static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 		struct ip_tunnel_parm *parms, int create)
 {
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
-	struct ip_tunnel *t, **tp, *nt;
+	struct ip_tunnel *t, *nt;
+	struct ip_tunnel __rcu **tp;
 	struct net_device *dev;
 	char name[IFNAMSIZ];
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
-	for (tp = __ipip6_bucket(sitn, parms); (t = *tp) != NULL; tp = &t->next) {
+	for (tp = __ipip6_bucket(sitn, parms);
+	    (t = rtnl_dereference(*tp)) != NULL;
+	     tp = &t->next) {
 		if (local == t->parms.iph.saddr &&
 		    remote == t->parms.iph.daddr &&
 		    parms->link == t->parms.link) {
@@ -340,7 +341,7 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a, int chg)
 
 	ASSERT_RTNL();
 
-	for (p = t->prl; p; p = p->next) {
+	for (p = rtnl_dereference(t->prl); p; p = rtnl_dereference(p->next)) {
 		if (p->addr == a->addr) {
 			if (chg) {
 				p->flags = a->flags;
@@ -451,15 +452,12 @@ static void ipip6_tunnel_uninit(struct net_device *dev)
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
 	if (dev == sitn->fb_tunnel_dev) {
-		spin_lock_bh(&ipip6_lock);
-		sitn->tunnels_wc[0] = NULL;
-		spin_unlock_bh(&ipip6_lock);
-		dev_put(dev);
+		rcu_assign_pointer(sitn->tunnels_wc[0], NULL);
 	} else {
 		ipip6_tunnel_unlink(sitn, netdev_priv(dev));
 		ipip6_tunnel_del_prl(netdev_priv(dev), NULL);
-		dev_put(dev);
 	}
+	dev_put(dev);
 }
 
 
@@ -590,7 +588,7 @@ __be32 try_6rd(struct in6_addr *v6dst, struct ip_tunnel *tunnel)
 #ifdef CONFIG_IPV6_SIT_6RD
 	if (ipv6_prefix_equal(v6dst, &tunnel->ip6rd.prefix,
 			      tunnel->ip6rd.prefixlen)) {
-		unsigned pbw0, pbi0;
+		unsigned int pbw0, pbi0;
 		int pbi1;
 		u32 d;
 


