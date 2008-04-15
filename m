From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 5/8][SIT]: Make tunnels hashes per-net.
Date: Tue, 15 Apr 2008 17:34:54 +0400
Message-ID: <4804AEFE.4020305@openvz.org>
References: <4804ACFA.1040003@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55065 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758363AbYDONAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 09:00:37 -0400
In-Reply-To: <4804ACFA.1040003@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just move all the hashes on the sit_net structure and
patch the rest of the code appropriately.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/sit.c |   45 +++++++++++++++++++++++++--------------------
 1 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index d0c1f2d..f82494b 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -70,15 +70,15 @@ static void ipip6_tunnel_setup(struct net_device *dev);
 
 static int sit_net_id;
 struct sit_net {
+	struct ip_tunnel *tunnels_r_l[HASH_SIZE];
+	struct ip_tunnel *tunnels_r[HASH_SIZE];
+	struct ip_tunnel *tunnels_l[HASH_SIZE];
+	struct ip_tunnel *tunnels_wc[1];
+	struct ip_tunnel **tunnels[4];
+
 	struct net_device *fb_tunnel_dev;
 };
 
-static struct ip_tunnel *tunnels_r_l[HASH_SIZE];
-static struct ip_tunnel *tunnels_r[HASH_SIZE];
-static struct ip_tunnel *tunnels_l[HASH_SIZE];
-static struct ip_tunnel *tunnels_wc[1];
-static struct ip_tunnel **tunnels[4] = { tunnels_wc, tunnels_l, tunnels_r, tunnels_r_l };
-
 static DEFINE_RWLOCK(ipip6_lock);
 
 static struct ip_tunnel * ipip6_tunnel_lookup(struct net *net,
@@ -87,21 +87,22 @@ static struct ip_tunnel * ipip6_tunnel_lookup(struct net *net,
 	unsigned h0 = HASH(remote);
 	unsigned h1 = HASH(local);
 	struct ip_tunnel *t;
+	struct sit_net *sitn = net_generic(net, sit_net_id);
 
-	for (t = tunnels_r_l[h0^h1]; t; t = t->next) {
+	for (t = sitn->tunnels_r_l[h0^h1]; t; t = t->next) {
 		if (local == t->parms.iph.saddr &&
 		    remote == t->parms.iph.daddr && (t->dev->flags&IFF_UP))
 			return t;
 	}
-	for (t = tunnels_r[h0]; t; t = t->next) {
+	for (t = sitn->tunnels_r[h0]; t; t = t->next) {
 		if (remote == t->parms.iph.daddr && (t->dev->flags&IFF_UP))
 			return t;
 	}
-	for (t = tunnels_l[h1]; t; t = t->next) {
+	for (t = sitn->tunnels_l[h1]; t; t = t->next) {
 		if (local == t->parms.iph.saddr && (t->dev->flags&IFF_UP))
 			return t;
 	}
-	if ((t = tunnels_wc[0]) != NULL && (t->dev->flags&IFF_UP))
+	if ((t = sitn->tunnels_wc[0]) != NULL && (t->dev->flags&IFF_UP))
 		return t;
 	return NULL;
 }
@@ -122,7 +123,7 @@ static struct ip_tunnel **__ipip6_bucket(struct sit_net *sitn,
 		prio |= 1;
 		h ^= HASH(local);
 	}
-	return &tunnels[prio][h];
+	return &sitn->tunnels[prio][h];
 }
 
 static inline struct ip_tunnel **ipip6_bucket(struct sit_net *sitn,
@@ -387,7 +388,7 @@ static void ipip6_tunnel_uninit(struct net_device *dev)
 
 	if (dev == sitn->fb_tunnel_dev) {
 		write_lock_bh(&ipip6_lock);
-		tunnels_wc[0] = NULL;
+		sitn->tunnels_wc[0] = NULL;
 		write_unlock_bh(&ipip6_lock);
 		dev_put(dev);
 	} else {
@@ -1050,6 +1051,8 @@ static int ipip6_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
+	struct net *net = dev_net(dev);
+	struct sit_net *sitn = net_generic(net, sit_net_id);
 
 	tunnel->dev = dev;
 	strcpy(tunnel->parms.name, dev->name);
@@ -1060,7 +1063,7 @@ static int ipip6_fb_tunnel_init(struct net_device *dev)
 	iph->ttl		= 64;
 
 	dev_hold(dev);
-	tunnels_wc[0]		= tunnel;
+	sitn->tunnels_wc[0]	= tunnel;
 	return 0;
 }
 
@@ -1070,7 +1073,7 @@ static struct xfrm_tunnel sit_handler = {
 	.priority	=	1,
 };
 
-static void __exit sit_destroy_tunnels(void)
+static void sit_destroy_tunnels(struct sit_net *sitn)
 {
 	int prio;
 
@@ -1078,7 +1081,7 @@ static void __exit sit_destroy_tunnels(void)
 		int h;
 		for (h = 0; h < HASH_SIZE; h++) {
 			struct ip_tunnel *t;
-			while ((t = tunnels[prio][h]) != NULL)
+			while ((t = sitn->tunnels[prio][h]) != NULL)
 				unregister_netdevice(t->dev);
 		}
 	}
@@ -1090,7 +1093,7 @@ static int sit_init_net(struct net *net)
 	struct sit_net *sitn;
 
 	err = -ENOMEM;
-	sitn = kmalloc(sizeof(struct sit_net), GFP_KERNEL);
+	sitn = kzalloc(sizeof(struct sit_net), GFP_KERNEL);
 	if (sitn == NULL)
 		goto err_alloc;
 
@@ -1098,6 +1101,11 @@ static int sit_init_net(struct net *net)
 	if (err < 0)
 		goto err_assign;
 
+	sitn->tunnels[0] = sitn->tunnels_wc;
+	sitn->tunnels[1] = sitn->tunnels_l;
+	sitn->tunnels[2] = sitn->tunnels_r;
+	sitn->tunnels[3] = sitn->tunnels_r_l;
+
 	sitn->fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel), "sit0",
 					   ipip6_tunnel_setup);
 	if (!sitn->fb_tunnel_dev) {
@@ -1129,6 +1137,7 @@ static void sit_exit_net(struct net *net)
 
 	sitn = net_generic(net, sit_net_id);
 	rtnl_lock();
+	sit_destroy_tunnels(sitn);
 	unregister_netdevice(sitn->fb_tunnel_dev);
 	rtnl_unlock();
 	kfree(sitn);
@@ -1143,10 +1152,6 @@ static void __exit sit_cleanup(void)
 {
 	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
 
-	rtnl_lock();
-	sit_destroy_tunnels();
-	rtnl_unlock();
-
 	unregister_pernet_gen_device(sit_net_id, &sit_net_ops);
 }
 
-- 
1.5.3.4

