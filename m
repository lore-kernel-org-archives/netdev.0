From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipip: get rid of ipip_lock
Date: Wed, 15 Sep 2010 19:27:56 +0200
Message-ID: <1284571676.2462.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56863 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421Ab0IOR2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 13:28:01 -0400
Received: by wyf22 with SMTP id 22so451661wyf.19
        for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 10:28:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As RTNL is held while doing tunnels inserts and deletes, we can remove
ipip_lock spinlock. My initial RCU conversion was conservative and
converted the rwlock to spinlock, with no RTNL requirement.

Use appropriate rcu annotations and modern lockdep checks as well.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Tested with CONFIG_PROVE_RCU=y

 net/ipv4/ipip.c |   71 ++++++++++++++++++++++++----------------------
 1 file changed, 38 insertions(+), 33 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 3c6f8f3..7f0e216 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -122,11 +122,11 @@
 
 static int ipip_net_id __read_mostly;
 struct ipip_net {
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
@@ -135,9 +135,8 @@ static void ipip_tunnel_init(struct net_device *dev);
 static void ipip_tunnel_setup(struct net_device *dev);
 
 /*
- * Locking : hash tables are protected by RCU and a spinlock
+ * Locking : hash tables are protected by RCU and RTNL
  */
-static DEFINE_SPINLOCK(ipip_lock);
 
 #define for_each_ip_tunnel_rcu(start) \
 	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
@@ -145,8 +144,8 @@ static DEFINE_SPINLOCK(ipip_lock);
 static struct ip_tunnel * ipip_tunnel_lookup(struct net *net,
 		__be32 remote, __be32 local)
 {
-	unsigned h0 = HASH(remote);
-	unsigned h1 = HASH(local);
+	unsigned int h0 = HASH(remote);
+	unsigned int h1 = HASH(local);
 	struct ip_tunnel *t;
 	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 
@@ -169,12 +168,12 @@ static struct ip_tunnel * ipip_tunnel_lookup(struct net *net,
 	return NULL;
 }
 
-static struct ip_tunnel **__ipip_bucket(struct ipip_net *ipn,
+static struct ip_tunnel __rcu **__ipip_bucket(struct ipip_net *ipn,
 		struct ip_tunnel_parm *parms)
 {
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
-	unsigned h = 0;
+	unsigned int h = 0;
 	int prio = 0;
 
 	if (remote) {
@@ -188,7 +187,7 @@ static struct ip_tunnel **__ipip_bucket(struct ipip_net *ipn,
 	return &ipn->tunnels[prio][h];
 }
 
-static inline struct ip_tunnel **ipip_bucket(struct ipip_net *ipn,
+static inline struct ip_tunnel __rcu **ipip_bucket(struct ipip_net *ipn,
 		struct ip_tunnel *t)
 {
 	return __ipip_bucket(ipn, &t->parms);
@@ -196,13 +195,14 @@ static inline struct ip_tunnel **ipip_bucket(struct ipip_net *ipn,
 
 static void ipip_tunnel_unlink(struct ipip_net *ipn, struct ip_tunnel *t)
 {
-	struct ip_tunnel **tp;
-
-	for (tp = ipip_bucket(ipn, t); *tp; tp = &(*tp)->next) {
-		if (t == *tp) {
-			spin_lock_bh(&ipip_lock);
-			*tp = t->next;
-			spin_unlock_bh(&ipip_lock);
+	struct ip_tunnel __rcu **tp;
+	struct ip_tunnel *iter;
+
+	for (tp = ipip_bucket(ipn, t);
+	     (iter = rcu_dereference_check(*tp, lockdep_rtnl_is_held())) != NULL;
+	     tp = &iter->next) {
+		if (t == iter) {
+			rcu_assign_pointer(*tp, t->next);
 			break;
 		}
 	}
@@ -210,12 +210,12 @@ static void ipip_tunnel_unlink(struct ipip_net *ipn, struct ip_tunnel *t)
 
 static void ipip_tunnel_link(struct ipip_net *ipn, struct ip_tunnel *t)
 {
-	struct ip_tunnel **tp = ipip_bucket(ipn, t);
+	struct ip_tunnel __rcu **tp = ipip_bucket(ipn, t);
 
-	spin_lock_bh(&ipip_lock);
-	t->next = *tp;
+	rcu_assign_pointer(t->next,
+			   rcu_dereference_check(*tp,
+						 lockdep_rtnl_is_held()));
 	rcu_assign_pointer(*tp, t);
-	spin_unlock_bh(&ipip_lock);
 }
 
 static struct ip_tunnel * ipip_tunnel_locate(struct net *net,
@@ -223,12 +223,15 @@ static struct ip_tunnel * ipip_tunnel_locate(struct net *net,
 {
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
-	struct ip_tunnel *t, **tp, *nt;
+	struct ip_tunnel *t, *nt;
+	struct ip_tunnel __rcu **tp;
 	struct net_device *dev;
 	char name[IFNAMSIZ];
 	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 
-	for (tp = __ipip_bucket(ipn, parms); (t = *tp) != NULL; tp = &t->next) {
+	for (tp = __ipip_bucket(ipn, parms);
+		 (t = rcu_dereference_check(*tp, lockdep_rtnl_is_held())) != NULL;
+		 tp = &t->next) {
 		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr)
 			return t;
 	}
@@ -268,16 +271,15 @@ failed_free:
 	return NULL;
 }
 
+/* called with RTNL */
 static void ipip_tunnel_uninit(struct net_device *dev)
 {
 	struct net *net = dev_net(dev);
 	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 
-	if (dev == ipn->fb_tunnel_dev) {
-		spin_lock_bh(&ipip_lock);
-		ipn->tunnels_wc[0] = NULL;
-		spin_unlock_bh(&ipip_lock);
-	} else
+	if (dev == ipn->fb_tunnel_dev)
+		rcu_assign_pointer(ipn->tunnels_wc[0], NULL);
+	else
 		ipip_tunnel_unlink(ipn, netdev_priv(dev));
 	dev_put(dev);
 }
@@ -741,7 +743,7 @@ static void __net_init ipip_fb_tunnel_init(struct net_device *dev)
 	iph->ihl		= 5;
 
 	dev_hold(dev);
-	ipn->tunnels_wc[0]	= tunnel;
+	rcu_assign_pointer(ipn->tunnels_wc[0], tunnel);
 }
 
 static struct xfrm_tunnel ipip_handler __read_mostly = {
@@ -760,11 +762,14 @@ static void ipip_destroy_tunnels(struct ipip_net *ipn, struct list_head *head)
 	for (prio = 1; prio < 4; prio++) {
 		int h;
 		for (h = 0; h < HASH_SIZE; h++) {
-			struct ip_tunnel *t = ipn->tunnels[prio][h];
+			struct ip_tunnel *t;
 
+			t = rcu_dereference_check(ipn->tunnels[prio][h],
+						  lockdep_rtnl_is_held());
 			while (t != NULL) {
 				unregister_netdevice_queue(t->dev, head);
-				t = t->next;
+				t = rcu_dereference_check(t->next,
+							  lockdep_rtnl_is_held());
 			}
 		}
 	}


