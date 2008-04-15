From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 4/8][GRE]: Make the fallback tunnel device per-net.
Date: Tue, 15 Apr 2008 16:57:11 +0400
Message-ID: <4804A627.2020807@openvz.org>
References: <4804A374.9040505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:34061 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751798AbYDOMWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:22:51 -0400
In-Reply-To: <4804A374.9040505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Everything is prepared for this change now. Create on in
init callback, use it over the code and destroy on net exit.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ip_gre.c |   63 +++++++++++++++++++++++++++--------------------------
 1 files changed, 32 insertions(+), 31 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 1a17c5b..a8ec090 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -126,10 +126,9 @@ static int ipgre_fb_tunnel_init(struct net_device *dev);
 
 static int ipgre_net_id;
 struct ipgre_net {
+	struct net_device *fb_tunnel_dev;
 };
 
-static struct net_device *ipgre_fb_tunnel_dev;
-
 /* Tunnel hash table */
 
 /*
@@ -168,6 +167,7 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net *net,
 	unsigned h0 = HASH(remote);
 	unsigned h1 = HASH(key);
 	struct ip_tunnel *t;
+	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 
 	for (t = tunnels_r_l[h0^h1]; t; t = t->next) {
 		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr) {
@@ -194,8 +194,8 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net *net,
 			return t;
 	}
 
-	if (ipgre_fb_tunnel_dev->flags&IFF_UP)
-		return netdev_priv(ipgre_fb_tunnel_dev);
+	if (ign->fb_tunnel_dev->flags&IFF_UP)
+		return netdev_priv(ign->fb_tunnel_dev);
 	return NULL;
 }
 
@@ -977,7 +977,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 		t = NULL;
-		if (dev == ipgre_fb_tunnel_dev) {
+		if (dev == ign->fb_tunnel_dev) {
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p))) {
 				err = -EFAULT;
 				break;
@@ -1016,7 +1016,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 
 		t = ipgre_tunnel_locate(net, &p, cmd == SIOCADDTUNNEL);
 
-		if (dev != ipgre_fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
+		if (dev != ign->fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
 				if (t->dev != dev) {
 					err = -EEXIST;
@@ -1071,7 +1071,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!capable(CAP_NET_ADMIN))
 			goto done;
 
-		if (dev == ipgre_fb_tunnel_dev) {
+		if (dev == ign->fb_tunnel_dev) {
 			err = -EFAULT;
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 				goto done;
@@ -1079,7 +1079,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 			if ((t = ipgre_tunnel_locate(net, &p, 0)) == NULL)
 				goto done;
 			err = -EPERM;
-			if (t == netdev_priv(ipgre_fb_tunnel_dev))
+			if (t == netdev_priv(ign->fb_tunnel_dev))
 				goto done;
 			dev = t->dev;
 		}
@@ -1270,7 +1270,7 @@ static int ipgre_tunnel_init(struct net_device *dev)
 	return 0;
 }
 
-static int __init ipgre_fb_tunnel_init(struct net_device *dev)
+static int ipgre_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
@@ -1308,8 +1308,25 @@ static int ipgre_init_net(struct net *net)
 	if (err < 0)
 		goto err_assign;
 
+	ign->fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel), "gre0",
+					   ipgre_tunnel_setup);
+	if (!ign->fb_tunnel_dev) {
+		err = -ENOMEM;
+		goto err_alloc_dev;
+	}
+
+	ign->fb_tunnel_dev->init = ipgre_fb_tunnel_init;
+	dev_net_set(ign->fb_tunnel_dev, net);
+
+	if ((err = register_netdev(ign->fb_tunnel_dev)))
+		goto err_reg_dev;
+
 	return 0;
 
+err_reg_dev:
+	free_netdev(ign->fb_tunnel_dev);
+err_alloc_dev:
+	/* nothing */
 err_assign:
 	kfree(ign);
 err_alloc:
@@ -1321,6 +1338,10 @@ static void ipgre_exit_net(struct net *net)
 	struct ipgre_net *ign;
 
 	ign = net_generic(net, ipgre_net_id);
+	rtnl_lock();
+	if (net != &init_net)
+		unregister_netdevice(ign->fb_tunnel_dev);
+	rtnl_unlock();
 	kfree(ign);
 }
 
@@ -1344,31 +1365,11 @@ static int __init ipgre_init(void)
 		return -EAGAIN;
 	}
 
-	ipgre_fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel), "gre0",
-					   ipgre_tunnel_setup);
-	if (!ipgre_fb_tunnel_dev) {
-		err = -ENOMEM;
-		goto err1;
-	}
-
-	ipgre_fb_tunnel_dev->init = ipgre_fb_tunnel_init;
-
-	if ((err = register_netdev(ipgre_fb_tunnel_dev)))
-		goto err2;
-
 	err = register_pernet_gen_device(&ipgre_net_id, &ipgre_net_ops);
 	if (err < 0)
-		goto err3;
-out:
+		inet_del_protocol(&ipgre_protocol, IPPROTO_GRE);
+
 	return err;
-err2:
-	free_netdev(ipgre_fb_tunnel_dev);
-err1:
-	inet_del_protocol(&ipgre_protocol, IPPROTO_GRE);
-	goto out;
-err3:
-	unregister_netdevice(ipgre_fb_tunnel_dev);
-	goto err1;
 }
 
 static void __exit ipgre_destroy_tunnels(void)
-- 
1.5.3.4

