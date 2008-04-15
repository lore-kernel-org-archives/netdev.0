From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 5/8][GRE]: Make tunnels hashes per-net.
Date: Tue, 15 Apr 2008 16:58:48 +0400
Message-ID: <4804A688.90703@openvz.org>
References: <4804A374.9040505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:34286 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752487AbYDOMY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:24:28 -0400
In-Reply-To: <4804A374.9040505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Very similar to what was done for the IPIP code.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ip_gre.c |   65 +++++++++++++++++++++++++---------------------------
 1 files changed, 31 insertions(+), 34 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index a8ec090..74d4c51 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -124,8 +124,12 @@ static void ipgre_tunnel_setup(struct net_device *dev);
 
 static int ipgre_fb_tunnel_init(struct net_device *dev);
 
+#define HASH_SIZE  16
+
 static int ipgre_net_id;
 struct ipgre_net {
+	struct ip_tunnel *tunnels[4][HASH_SIZE];
+
 	struct net_device *fb_tunnel_dev;
 };
 
@@ -147,15 +151,12 @@ struct ipgre_net {
    will match fallback tunnel.
  */
 
-#define HASH_SIZE  16
 #define HASH(addr) (((__force u32)addr^((__force u32)addr>>4))&0xF)
 
-static struct ip_tunnel *tunnels[4][HASH_SIZE];
-
-#define tunnels_r_l	(tunnels[3])
-#define tunnels_r	(tunnels[2])
-#define tunnels_l	(tunnels[1])
-#define tunnels_wc	(tunnels[0])
+#define tunnels_r_l	tunnels[3]
+#define tunnels_r	tunnels[2]
+#define tunnels_l	tunnels[1]
+#define tunnels_wc	tunnels[0]
 
 static DEFINE_RWLOCK(ipgre_lock);
 
@@ -169,19 +170,19 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net *net,
 	struct ip_tunnel *t;
 	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 
-	for (t = tunnels_r_l[h0^h1]; t; t = t->next) {
+	for (t = ign->tunnels_r_l[h0^h1]; t; t = t->next) {
 		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr) {
 			if (t->parms.i_key == key && (t->dev->flags&IFF_UP))
 				return t;
 		}
 	}
-	for (t = tunnels_r[h0^h1]; t; t = t->next) {
+	for (t = ign->tunnels_r[h0^h1]; t; t = t->next) {
 		if (remote == t->parms.iph.daddr) {
 			if (t->parms.i_key == key && (t->dev->flags&IFF_UP))
 				return t;
 		}
 	}
-	for (t = tunnels_l[h1]; t; t = t->next) {
+	for (t = ign->tunnels_l[h1]; t; t = t->next) {
 		if (local == t->parms.iph.saddr ||
 		     (local == t->parms.iph.daddr &&
 		      ipv4_is_multicast(local))) {
@@ -189,7 +190,7 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net *net,
 				return t;
 		}
 	}
-	for (t = tunnels_wc[h1]; t; t = t->next) {
+	for (t = ign->tunnels_wc[h1]; t; t = t->next) {
 		if (t->parms.i_key == key && (t->dev->flags&IFF_UP))
 			return t;
 	}
@@ -215,7 +216,7 @@ static struct ip_tunnel **__ipgre_bucket(struct ipgre_net *ign,
 		h ^= HASH(remote);
 	}
 
-	return &tunnels[prio][h];
+	return &ign->tunnels[prio][h];
 }
 
 static inline struct ip_tunnel **ipgre_bucket(struct ipgre_net *ign,
@@ -1274,6 +1275,7 @@ static int ipgre_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
+	struct ipgre_net *ign = net_generic(dev_net(dev), ipgre_net_id);
 
 	tunnel->dev = dev;
 	strcpy(tunnel->parms.name, dev->name);
@@ -1284,7 +1286,7 @@ static int ipgre_fb_tunnel_init(struct net_device *dev)
 	tunnel->hlen		= sizeof(struct iphdr) + 4;
 
 	dev_hold(dev);
-	tunnels_wc[0]		= tunnel;
+	ign->tunnels_wc[0]	= tunnel;
 	return 0;
 }
 
@@ -1294,13 +1296,27 @@ static struct net_protocol ipgre_protocol = {
 	.err_handler	=	ipgre_err,
 };
 
+static void ipgre_destroy_tunnels(struct ipgre_net *ign)
+{
+	int prio;
+
+	for (prio = 0; prio < 4; prio++) {
+		int h;
+		for (h = 0; h < HASH_SIZE; h++) {
+			struct ip_tunnel *t;
+			while ((t = ign->tunnels[prio][h]) != NULL)
+				unregister_netdevice(t->dev);
+		}
+	}
+}
+
 static int ipgre_init_net(struct net *net)
 {
 	int err;
 	struct ipgre_net *ign;
 
 	err = -ENOMEM;
-	ign = kmalloc(sizeof(struct ipgre_net), GFP_KERNEL);
+	ign = kzalloc(sizeof(struct ipgre_net), GFP_KERNEL);
 	if (ign == NULL)
 		goto err_alloc;
 
@@ -1339,8 +1355,7 @@ static void ipgre_exit_net(struct net *net)
 
 	ign = net_generic(net, ipgre_net_id);
 	rtnl_lock();
-	if (net != &init_net)
-		unregister_netdevice(ign->fb_tunnel_dev);
+	ipgre_destroy_tunnels(ign);
 	rtnl_unlock();
 	kfree(ign);
 }
@@ -1372,29 +1387,11 @@ static int __init ipgre_init(void)
 	return err;
 }
 
-static void __exit ipgre_destroy_tunnels(void)
-{
-	int prio;
-
-	for (prio = 0; prio < 4; prio++) {
-		int h;
-		for (h = 0; h < HASH_SIZE; h++) {
-			struct ip_tunnel *t;
-			while ((t = tunnels[prio][h]) != NULL)
-				unregister_netdevice(t->dev);
-		}
-	}
-}
-
 static void __exit ipgre_fini(void)
 {
 	if (inet_del_protocol(&ipgre_protocol, IPPROTO_GRE) < 0)
 		printk(KERN_INFO "ipgre close: can't remove protocol\n");
 
-	rtnl_lock();
-	ipgre_destroy_tunnels();
-	rtnl_unlock();
-
 	unregister_pernet_gen_device(ipgre_net_id, &ipgre_net_ops);
 }
 
-- 
1.5.3.4

