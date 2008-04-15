From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 4/7][IP6TUNNEL]: Make the fallback tunnel device
 per-net.
Date: Tue, 15 Apr 2008 18:04:16 +0400
Message-ID: <4804B5E0.6090708@openvz.org>
References: <4804B478.3040606@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58781 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753588AbYDON34 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 09:29:56 -0400
In-Reply-To: <4804B478.3040606@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the code, that reference it already has the ip6_tnl_net pointer,
so s/ip6_fb_tnl_dev/ip6n->fb_tnl_dev/ and move creation/releasing
code into net init/exit ops.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/ip6_tunnel.c |   48 ++++++++++++++++++++++++------------------------
 1 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 72485a3..511a6c4 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -82,12 +82,10 @@ static void ip6_tnl_dev_setup(struct net_device *dev);
 
 static int ip6_tnl_net_id;
 struct ip6_tnl_net {
+	/* the IPv6 tunnel fallback device */
+	struct net_device *fb_tnl_dev;
 };
 
-/* the IPv6 tunnel fallback device */
-static struct net_device *ip6_fb_tnl_dev;
-
-
 /* lists for storing tunnels in use */
 static struct ip6_tnl *tnls_r_l[HASH_SIZE];
 static struct ip6_tnl *tnls_wc[1];
@@ -314,7 +312,7 @@ ip6_tnl_dev_uninit(struct net_device *dev)
 	struct net *net = dev_net(dev);
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
-	if (dev == ip6_fb_tnl_dev) {
+	if (dev == ip6n->fb_tnl_dev) {
 		write_lock_bh(&ip6_tnl_lock);
 		tnls_wc[0] = NULL;
 		write_unlock_bh(&ip6_tnl_lock);
@@ -1209,7 +1207,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	switch (cmd) {
 	case SIOCGETTUNNEL:
-		if (dev == ip6_fb_tnl_dev) {
+		if (dev == ip6n->fb_tnl_dev) {
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p))) {
 				err = -EFAULT;
 				break;
@@ -1236,7 +1234,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		    p.proto != 0)
 			break;
 		t = ip6_tnl_locate(net, &p, cmd == SIOCADDTUNNEL);
-		if (dev != ip6_fb_tnl_dev && cmd == SIOCCHGTUNNEL) {
+		if (dev != ip6n->fb_tnl_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
 				if (t->dev != dev) {
 					err = -EEXIST;
@@ -1263,7 +1261,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!capable(CAP_NET_ADMIN))
 			break;
 
-		if (dev == ip6_fb_tnl_dev) {
+		if (dev == ip6n->fb_tnl_dev) {
 			err = -EFAULT;
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p)))
 				break;
@@ -1271,7 +1269,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			if ((t = ip6_tnl_locate(net, &p, 0)) == NULL)
 				break;
 			err = -EPERM;
-			if (t->dev == ip6_fb_tnl_dev)
+			if (t->dev == ip6n->fb_tnl_dev)
 				break;
 			dev = t->dev;
 		}
@@ -1413,8 +1411,25 @@ static int ip6_tnl_init_net(struct net *net)
 	if (err < 0)
 		goto err_assign;
 
+	err = -ENOMEM;
+	ip6n->fb_tnl_dev = alloc_netdev(sizeof(struct ip6_tnl), "ip6tnl0",
+				      ip6_tnl_dev_setup);
+
+	if (!ip6n->fb_tnl_dev)
+		goto err_alloc_dev;
+
+	ip6n->fb_tnl_dev->init = ip6_fb_tnl_dev_init;
+	dev_net_set(ip6n->fb_tnl_dev, net);
+
+	err = register_netdev(ip6n->fb_tnl_dev);
+	if (err < 0)
+		goto err_register;
 	return 0;
 
+err_register:
+	free_netdev(ip6n->fb_tnl_dev);
+err_alloc_dev:
+	/* nothing */
 err_assign:
 	kfree(ip6n);
 err_alloc:
@@ -1455,27 +1470,12 @@ static int __init ip6_tunnel_init(void)
 		err = -EAGAIN;
 		goto unreg_ip4ip6;
 	}
-	ip6_fb_tnl_dev = alloc_netdev(sizeof(struct ip6_tnl), "ip6tnl0",
-				      ip6_tnl_dev_setup);
-
-	if (!ip6_fb_tnl_dev) {
-		err = -ENOMEM;
-		goto fail;
-	}
-	ip6_fb_tnl_dev->init = ip6_fb_tnl_dev_init;
-
-	if ((err = register_netdev(ip6_fb_tnl_dev))) {
-		free_netdev(ip6_fb_tnl_dev);
-		goto fail;
-	}
 
 	err = register_pernet_gen_device(&ip6_tnl_net_id, &ip6_tnl_net_ops);
 	if (err < 0)
 		goto err_pernet;
 	return 0;
 err_pernet:
-	unregister_netdevice(ip6_fb_tnl_dev);
-fail:
 	xfrm6_tunnel_deregister(&ip6ip6_handler, AF_INET6);
 unreg_ip4ip6:
 	xfrm6_tunnel_deregister(&ip4ip6_handler, AF_INET);
-- 
1.5.3.4

