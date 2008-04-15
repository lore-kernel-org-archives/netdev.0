From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 2/8][IPIP]: Make the fallback tunnel device per-net.
Date: Tue, 15 Apr 2008 16:29:00 +0400
Message-ID: <48049F8C.90502@openvz.org>
References: <48049E9C.1020207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44810 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758049AbYDOLyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 07:54:40 -0400
In-Reply-To: <48049E9C.1020207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create on in ipip_init_net(), use it all over the code (the
proper place to get the net from already exists) and destroy
in ipip_net_exit().

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ipip.c |   67 ++++++++++++++++++++++++++++--------------------------
 1 files changed, 35 insertions(+), 32 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index e39a4c2..e657a66 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -123,14 +123,13 @@
 
 static int ipip_net_id;
 struct ipip_net {
+	struct net_device *fb_tunnel_dev;
 };
 
 static int ipip_fb_tunnel_init(struct net_device *dev);
 static int ipip_tunnel_init(struct net_device *dev);
 static void ipip_tunnel_setup(struct net_device *dev);
 
-static struct net_device *ipip_fb_tunnel_dev;
-
 static struct ip_tunnel *tunnels_r_l[HASH_SIZE];
 static struct ip_tunnel *tunnels_r[HASH_SIZE];
 static struct ip_tunnel *tunnels_l[HASH_SIZE];
@@ -257,7 +256,10 @@ failed_free:
 
 static void ipip_tunnel_uninit(struct net_device *dev)
 {
-	if (dev == ipip_fb_tunnel_dev) {
+	struct net *net = dev_net(dev);
+	struct ipip_net *ipn = net_generic(net, ipip_net_id);
+
+	if (dev == ipn->fb_tunnel_dev) {
 		write_lock_bh(&ipip_lock);
 		tunnels_wc[0] = NULL;
 		write_unlock_bh(&ipip_lock);
@@ -693,11 +695,13 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	int err = 0;
 	struct ip_tunnel_parm p;
 	struct ip_tunnel *t;
+	struct net *net = dev_net(dev);
+	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 		t = NULL;
-		if (dev == ipip_fb_tunnel_dev) {
+		if (dev == ipn->fb_tunnel_dev) {
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p))) {
 				err = -EFAULT;
 				break;
@@ -730,7 +734,7 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 
 		t = ipip_tunnel_locate(&p, cmd == SIOCADDTUNNEL);
 
-		if (dev != ipip_fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
+		if (dev != ipn->fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
 				if (t->dev != dev) {
 					err = -EEXIST;
@@ -776,7 +780,7 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!capable(CAP_NET_ADMIN))
 			goto done;
 
-		if (dev == ipip_fb_tunnel_dev) {
+		if (dev == ipn->fb_tunnel_dev) {
 			err = -EFAULT;
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 				goto done;
@@ -784,7 +788,7 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 			if ((t = ipip_tunnel_locate(&p, 0)) == NULL)
 				goto done;
 			err = -EPERM;
-			if (t->dev == ipip_fb_tunnel_dev)
+			if (t->dev == ipn->fb_tunnel_dev)
 				goto done;
 			dev = t->dev;
 		}
@@ -847,7 +851,7 @@ static int ipip_tunnel_init(struct net_device *dev)
 	return 0;
 }
 
-static int __init ipip_fb_tunnel_init(struct net_device *dev)
+static int ipip_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
@@ -887,8 +891,26 @@ static int ipip_init_net(struct net *net)
 	if (err < 0)
 		goto err_assign;
 
+	ipn->fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel),
+					   "tunl0",
+					   ipip_tunnel_setup);
+	if (!ipn->fb_tunnel_dev) {
+		err = -ENOMEM;
+		goto err_alloc_dev;
+	}
+
+	ipn->fb_tunnel_dev->init = ipip_fb_tunnel_init;
+	dev_net_set(ipn->fb_tunnel_dev, net);
+
+	if ((err = register_netdev(ipn->fb_tunnel_dev)))
+		goto err_reg_dev;
+
 	return 0;
 
+err_reg_dev:
+	free_netdev(ipn->fb_tunnel_dev);
+err_alloc_dev:
+	/* nothing */
 err_assign:
 	kfree(ipn);
 err_alloc:
@@ -900,6 +922,9 @@ static void ipip_exit_net(struct net *net)
 	struct ipip_net *ipn;
 
 	ipn = net_generic(net, ipip_net_id);
+	rtnl_lock();
+	unregister_netdevice(ipn->fb_tunnel_dev);
+	rtnl_unlock();
 	kfree(ipn);
 }
 
@@ -919,32 +944,11 @@ static int __init ipip_init(void)
 		return -EAGAIN;
 	}
 
-	ipip_fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel),
-					   "tunl0",
-					   ipip_tunnel_setup);
-	if (!ipip_fb_tunnel_dev) {
-		err = -ENOMEM;
-		goto err1;
-	}
-
-	ipip_fb_tunnel_dev->init = ipip_fb_tunnel_init;
-
-	if ((err = register_netdev(ipip_fb_tunnel_dev)))
-		goto err2;
-
 	err = register_pernet_gen_device(&ipip_net_id, &ipip_net_ops);
 	if (err)
-		goto err3;
- out:
+		xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
+
 	return err;
- err2:
-	free_netdev(ipip_fb_tunnel_dev);
- err1:
-	xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
-	goto out;
-err3:
-	unregister_netdevice(ipip_fb_tunnel_dev);
-	goto err1;
 }
 
 static void __exit ipip_destroy_tunnels(void)
@@ -968,7 +972,6 @@ static void __exit ipip_fini(void)
 
 	rtnl_lock();
 	ipip_destroy_tunnels();
-	unregister_netdevice(ipip_fb_tunnel_dev);
 	rtnl_unlock();
 
 	unregister_pernet_gen_device(ipip_net_id, &ipip_net_ops);
