From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 5/7][IP6TUNNEL]: Make tunnels hashes per-net.
Date: Tue, 15 Apr 2008 18:06:11 +0400
Message-ID: <4804B653.3020201@openvz.org>
References: <4804B478.3040606@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51384 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755184AbYDONbw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 09:31:52 -0400
In-Reply-To: <4804B478.3040606@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move hashes in the struct ip6_tnl_net, replace tnls_xxx[] with 
ip6n->tnlx_xxx[] and handle init and exit appropriately.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/ip6_tunnel.c |   63 ++++++++++++++++++++++++++----------------------
 1 files changed, 34 insertions(+), 29 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 511a6c4..7d2aa6e 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -84,13 +84,12 @@ static int ip6_tnl_net_id;
 struct ip6_tnl_net {
 	/* the IPv6 tunnel fallback device */
 	struct net_device *fb_tnl_dev;
+	/* lists for storing tunnels in use */
+	struct ip6_tnl *tnls_r_l[HASH_SIZE];
+	struct ip6_tnl *tnls_wc[1];
+	struct ip6_tnl **tnls[2];
 };
 
-/* lists for storing tunnels in use */
-static struct ip6_tnl *tnls_r_l[HASH_SIZE];
-static struct ip6_tnl *tnls_wc[1];
-static struct ip6_tnl **tnls[2] = { tnls_wc, tnls_r_l };
-
 /* lock for the tunnel lists */
 static DEFINE_RWLOCK(ip6_tnl_lock);
 
@@ -139,14 +138,15 @@ ip6_tnl_lookup(struct net *net, struct in6_addr *remote, struct in6_addr *local)
 	unsigned h0 = HASH(remote);
 	unsigned h1 = HASH(local);
 	struct ip6_tnl *t;
+	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
-	for (t = tnls_r_l[h0 ^ h1]; t; t = t->next) {
+	for (t = ip6n->tnls_r_l[h0 ^ h1]; t; t = t->next) {
 		if (ipv6_addr_equal(local, &t->parms.laddr) &&
 		    ipv6_addr_equal(remote, &t->parms.raddr) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
-	if ((t = tnls_wc[0]) != NULL && (t->dev->flags & IFF_UP))
+	if ((t = ip6n->tnls_wc[0]) != NULL && (t->dev->flags & IFF_UP))
 		return t;
 
 	return NULL;
@@ -175,7 +175,7 @@ ip6_tnl_bucket(struct ip6_tnl_net *ip6n, struct ip6_tnl_parm *p)
 		prio = 1;
 		h = HASH(remote) ^ HASH(local);
 	}
-	return &tnls[prio][h];
+	return &ip6n->tnls[prio][h];
 }
 
 /**
@@ -314,7 +314,7 @@ ip6_tnl_dev_uninit(struct net_device *dev)
 
 	if (dev == ip6n->fb_tnl_dev) {
 		write_lock_bh(&ip6_tnl_lock);
-		tnls_wc[0] = NULL;
+		ip6n->tnls_wc[0] = NULL;
 		write_unlock_bh(&ip6_tnl_lock);
 	} else {
 		ip6_tnl_unlink(ip6n, t);
@@ -1378,10 +1378,13 @@ static int
 ip6_fb_tnl_dev_init(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
+	struct net *net = dev_net(dev);
+	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
+
 	ip6_tnl_dev_init_gen(dev);
 	t->parms.proto = IPPROTO_IPV6;
 	dev_hold(dev);
-	tnls_wc[0] = t;
+	ip6n->tnls_wc[0] = t;
 	return 0;
 }
 
@@ -1397,13 +1400,27 @@ static struct xfrm6_tunnel ip6ip6_handler = {
 	.priority	=	1,
 };
 
+static void ip6_tnl_destroy_tunnels(struct ip6_tnl_net *ip6n)
+{
+	int h;
+	struct ip6_tnl *t;
+
+	for (h = 0; h < HASH_SIZE; h++) {
+		while ((t = ip6n->tnls_r_l[h]) != NULL)
+			unregister_netdevice(t->dev);
+	}
+
+	t = ip6n->tnls_wc[0];
+	unregister_netdevice(t->dev);
+}
+
 static int ip6_tnl_init_net(struct net *net)
 {
 	int err;
 	struct ip6_tnl_net *ip6n;
 
 	err = -ENOMEM;
-	ip6n = kmalloc(sizeof(struct ip6_tnl_net), GFP_KERNEL);
+	ip6n = kzalloc(sizeof(struct ip6_tnl_net), GFP_KERNEL);
 	if (ip6n == NULL)
 		goto err_alloc;
 
@@ -1411,6 +1428,9 @@ static int ip6_tnl_init_net(struct net *net)
 	if (err < 0)
 		goto err_assign;
 
+	ip6n->tnls[0] = ip6n->tnls_wc;
+	ip6n->tnls[1] = ip6n->tnls_r_l;
+
 	err = -ENOMEM;
 	ip6n->fb_tnl_dev = alloc_netdev(sizeof(struct ip6_tnl), "ip6tnl0",
 				      ip6_tnl_dev_setup);
@@ -1441,6 +1461,9 @@ static void ip6_tnl_exit_net(struct net *net)
 	struct ip6_tnl_net *ip6n;
 
 	ip6n = net_generic(net, ip6_tnl_net_id);
+	rtnl_lock();
+	ip6_tnl_destroy_tunnels(ip6n);
+	rtnl_unlock();
 	kfree(ip6n);
 }
 
@@ -1483,20 +1506,6 @@ out:
 	return err;
 }
 
-static void __exit ip6_tnl_destroy_tunnels(void)
-{
-	int h;
-	struct ip6_tnl *t;
-
-	for (h = 0; h < HASH_SIZE; h++) {
-		while ((t = tnls_r_l[h]) != NULL)
-			unregister_netdevice(t->dev);
-	}
-
-	t = tnls_wc[0];
-	unregister_netdevice(t->dev);
-}
-
 /**
  * ip6_tunnel_cleanup - free resources and unregister protocol
  **/
@@ -1509,10 +1518,6 @@ static void __exit ip6_tunnel_cleanup(void)
 	if (xfrm6_tunnel_deregister(&ip6ip6_handler, AF_INET6))
 		printk(KERN_INFO "ip6_tunnel close: can't deregister ip6ip6\n");
 
-	rtnl_lock();
-	ip6_tnl_destroy_tunnels();
-	rtnl_unlock();
-
 	unregister_pernet_gen_device(ip6_tnl_net_id, &ip6_tnl_net_ops);
 }
 
-- 
1.5.3.4

