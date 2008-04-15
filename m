From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 5/8][IPIP]: Make tunnels hashes per net.
Date: Tue, 15 Apr 2008 16:36:09 +0400
Message-ID: <4804A139.3000705@openvz.org>
References: <48049E9C.1020207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:46869 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760196AbYDOMBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:01:49 -0400
In-Reply-To: <48049E9C.1020207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Either net or ipip_net already exists in all the required 
places, so just use one.

Besides, tune net_init and net_exit calls to respectively 
initialize the hashes and destroy devices.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ipip.c |   68 +++++++++++++++++++++++++++++-------------------------
 1 files changed, 36 insertions(+), 32 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index da71470..9c2939b 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -123,6 +123,12 @@
 
 static int ipip_net_id;
 struct ipip_net {
+	struct ip_tunnel *tunnels_r_l[HASH_SIZE];
+	struct ip_tunnel *tunnels_r[HASH_SIZE];
+	struct ip_tunnel *tunnels_l[HASH_SIZE];
+	struct ip_tunnel *tunnels_wc[1];
+	struct ip_tunnel **tunnels[4];
+
 	struct net_device *fb_tunnel_dev;
 };
 
@@ -130,12 +136,6 @@ static int ipip_fb_tunnel_init(struct net_device *dev);
 static int ipip_tunnel_init(struct net_device *dev);
 static void ipip_tunnel_setup(struct net_device *dev);
 
-static struct ip_tunnel *tunnels_r_l[HASH_SIZE];
-static struct ip_tunnel *tunnels_r[HASH_SIZE];
-static struct ip_tunnel *tunnels_l[HASH_SIZE];
-static struct ip_tunnel *tunnels_wc[1];
-static struct ip_tunnel **tunnels[4] = { tunnels_wc, tunnels_l, tunnels_r, tunnels_r_l };
-
 static DEFINE_RWLOCK(ipip_lock);
 
 static struct ip_tunnel * ipip_tunnel_lookup(struct net *net,
@@ -144,21 +144,22 @@ static struct ip_tunnel * ipip_tunnel_lookup(struct net *net,
 	unsigned h0 = HASH(remote);
 	unsigned h1 = HASH(local);
 	struct ip_tunnel *t;
+	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 
-	for (t = tunnels_r_l[h0^h1]; t; t = t->next) {
+	for (t = ipn->tunnels_r_l[h0^h1]; t; t = t->next) {
 		if (local == t->parms.iph.saddr &&
 		    remote == t->parms.iph.daddr && (t->dev->flags&IFF_UP))
 			return t;
 	}
-	for (t = tunnels_r[h0]; t; t = t->next) {
+	for (t = ipn->tunnels_r[h0]; t; t = t->next) {
 		if (remote == t->parms.iph.daddr && (t->dev->flags&IFF_UP))
 			return t;
 	}
-	for (t = tunnels_l[h1]; t; t = t->next) {
+	for (t = ipn->tunnels_l[h1]; t; t = t->next) {
 		if (local == t->parms.iph.saddr && (t->dev->flags&IFF_UP))
 			return t;
 	}
-	if ((t = tunnels_wc[0]) != NULL && (t->dev->flags&IFF_UP))
+	if ((t = ipn->tunnels_wc[0]) != NULL && (t->dev->flags&IFF_UP))
 		return t;
 	return NULL;
 }
@@ -179,7 +180,7 @@ static struct ip_tunnel **__ipip_bucket(struct ipip_net *ipn,
 		prio |= 1;
 		h ^= HASH(local);
 	}
-	return &tunnels[prio][h];
+	return &ipn->tunnels[prio][h];
 }
 
 static inline struct ip_tunnel **ipip_bucket(struct ipip_net *ipn,
@@ -266,7 +267,7 @@ static void ipip_tunnel_uninit(struct net_device *dev)
 
 	if (dev == ipn->fb_tunnel_dev) {
 		write_lock_bh(&ipip_lock);
-		tunnels_wc[0] = NULL;
+		ipn->tunnels_wc[0] = NULL;
 		write_unlock_bh(&ipip_lock);
 	} else
 		ipip_tunnel_unlink(ipn, netdev_priv(dev));
@@ -861,6 +862,7 @@ static int ipip_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
+	struct ipip_net *ipn = net_generic(dev_net(dev), ipip_net_id);
 
 	tunnel->dev = dev;
 	strcpy(tunnel->parms.name, dev->name);
@@ -870,7 +872,7 @@ static int ipip_fb_tunnel_init(struct net_device *dev)
 	iph->ihl		= 5;
 
 	dev_hold(dev);
-	tunnels_wc[0]		= tunnel;
+	ipn->tunnels_wc[0]	= tunnel;
 	return 0;
 }
 
@@ -883,13 +885,27 @@ static struct xfrm_tunnel ipip_handler = {
 static char banner[] __initdata =
 	KERN_INFO "IPv4 over IPv4 tunneling driver\n";
 
+static void ipip_destroy_tunnels(struct ipip_net *ipn)
+{
+	int prio;
+
+	for (prio = 1; prio < 4; prio++) {
+		int h;
+		for (h = 0; h < HASH_SIZE; h++) {
+			struct ip_tunnel *t;
+			while ((t = ipn->tunnels[prio][h]) != NULL)
+				unregister_netdevice(t->dev);
+		}
+	}
+}
+
 static int ipip_init_net(struct net *net)
 {
 	int err;
 	struct ipip_net *ipn;
 
 	err = -ENOMEM;
-	ipn = kmalloc(sizeof(struct ipip_net), GFP_KERNEL);
+	ipn = kzalloc(sizeof(struct ipip_net), GFP_KERNEL);
 	if (ipn == NULL)
 		goto err_alloc;
 
@@ -897,6 +913,11 @@ static int ipip_init_net(struct net *net)
 	if (err < 0)
 		goto err_assign;
 
+	ipn->tunnels[0] = ipn->tunnels_wc;
+	ipn->tunnels[1] = ipn->tunnels_l;
+	ipn->tunnels[2] = ipn->tunnels_r;
+	ipn->tunnels[3] = ipn->tunnels_r_l;
+
 	ipn->fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel),
 					   "tunl0",
 					   ipip_tunnel_setup);
@@ -929,6 +950,7 @@ static void ipip_exit_net(struct net *net)
 
 	ipn = net_generic(net, ipip_net_id);
 	rtnl_lock();
+	ipip_destroy_tunnels(ipn);
 	unregister_netdevice(ipn->fb_tunnel_dev);
 	rtnl_unlock();
 	kfree(ipn);
@@ -957,29 +979,11 @@ static int __init ipip_init(void)
 	return err;
 }
 
-static void __exit ipip_destroy_tunnels(void)
-{
-	int prio;
-
-	for (prio = 1; prio < 4; prio++) {
-		int h;
-		for (h = 0; h < HASH_SIZE; h++) {
-			struct ip_tunnel *t;
-			while ((t = tunnels[prio][h]) != NULL)
-				unregister_netdevice(t->dev);
-		}
-	}
-}
-
 static void __exit ipip_fini(void)
 {
 	if (xfrm4_tunnel_deregister(&ipip_handler, AF_INET))
 		printk(KERN_INFO "ipip close: can't deregister tunnel\n");
 
-	rtnl_lock();
-	ipip_destroy_tunnels();
-	rtnl_unlock();
-
 	unregister_pernet_gen_device(ipip_net_id, &ipip_net_ops);
 }
 
-- 
1.5.3.4

