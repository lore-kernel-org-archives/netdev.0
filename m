From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 4/8][SIT]: Make the fallback tunnel device per-net
Date: Tue, 15 Apr 2008 17:33:10 +0400
Message-ID: <4804AE96.6000805@openvz.org>
References: <4804ACFA.1040003@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:54609 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753366AbYDOM6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:58:54 -0400
In-Reply-To: <4804ACFA.1040003@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate and register one in sit_init_net, use sitn->fb_tunnel_dev
over the code and unregister one in sit_exit_net.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/sit.c |   61 ++++++++++++++++++++++++++-----------------------------
 1 files changed, 29 insertions(+), 32 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index e85ddcd..d0c1f2d 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -70,10 +70,9 @@ static void ipip6_tunnel_setup(struct net_device *dev);
 
 static int sit_net_id;
 struct sit_net {
+	struct net_device *fb_tunnel_dev;
 };
 
-static struct net_device *ipip6_fb_tunnel_dev;
-
 static struct ip_tunnel *tunnels_r_l[HASH_SIZE];
 static struct ip_tunnel *tunnels_r[HASH_SIZE];
 static struct ip_tunnel *tunnels_l[HASH_SIZE];
@@ -386,7 +385,7 @@ static void ipip6_tunnel_uninit(struct net_device *dev)
 	struct net *net = dev_net(dev);
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
-	if (dev == ipip6_fb_tunnel_dev) {
+	if (dev == sitn->fb_tunnel_dev) {
 		write_lock_bh(&ipip6_lock);
 		tunnels_wc[0] = NULL;
 		write_unlock_bh(&ipip6_lock);
@@ -862,7 +861,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 		t = NULL;
-		if (dev == ipip6_fb_tunnel_dev) {
+		if (dev == sitn->fb_tunnel_dev) {
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p))) {
 				err = -EFAULT;
 				break;
@@ -895,7 +894,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 
 		t = ipip6_tunnel_locate(net, &p, cmd == SIOCADDTUNNEL);
 
-		if (dev != ipip6_fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
+		if (dev != sitn->fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
 				if (t->dev != dev) {
 					err = -EEXIST;
@@ -940,7 +939,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!capable(CAP_NET_ADMIN))
 			goto done;
 
-		if (dev == ipip6_fb_tunnel_dev) {
+		if (dev == sitn->fb_tunnel_dev) {
 			err = -EFAULT;
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 				goto done;
@@ -948,7 +947,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 			if ((t = ipip6_tunnel_locate(net, &p, 0)) == NULL)
 				goto done;
 			err = -EPERM;
-			if (t == netdev_priv(ipip6_fb_tunnel_dev))
+			if (t == netdev_priv(sitn->fb_tunnel_dev))
 				goto done;
 			dev = t->dev;
 		}
@@ -964,7 +963,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (cmd != SIOCGETPRL && !capable(CAP_NET_ADMIN))
 			goto done;
 		err = -EINVAL;
-		if (dev == ipip6_fb_tunnel_dev)
+		if (dev == sitn->fb_tunnel_dev)
 			goto done;
 		err = -EFAULT;
 		if (copy_from_user(&prl, ifr->ifr_ifru.ifru_data, sizeof(prl)))
@@ -1047,7 +1046,7 @@ static int ipip6_tunnel_init(struct net_device *dev)
 	return 0;
 }
 
-static int __init ipip6_fb_tunnel_init(struct net_device *dev)
+static int ipip6_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
@@ -1099,8 +1098,25 @@ static int sit_init_net(struct net *net)
 	if (err < 0)
 		goto err_assign;
 
+	sitn->fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel), "sit0",
+					   ipip6_tunnel_setup);
+	if (!sitn->fb_tunnel_dev) {
+		err = -ENOMEM;
+		goto err_alloc_dev;
+	}
+
+	sitn->fb_tunnel_dev->init = ipip6_fb_tunnel_init;
+	dev_net_set(sitn->fb_tunnel_dev, net);
+
+	if ((err = register_netdev(sitn->fb_tunnel_dev)))
+		goto err_reg_dev;
+
 	return 0;
 
+err_reg_dev:
+	free_netdev(sitn->fb_tunnel_dev);
+err_alloc_dev:
+	/* nothing */
 err_assign:
 	kfree(sitn);
 err_alloc:
@@ -1112,6 +1128,9 @@ static void sit_exit_net(struct net *net)
 	struct sit_net *sitn;
 
 	sitn = net_generic(net, sit_net_id);
+	rtnl_lock();
+	unregister_netdevice(sitn->fb_tunnel_dev);
+	rtnl_unlock();
 	kfree(sitn);
 }
 
@@ -1126,7 +1145,6 @@ static void __exit sit_cleanup(void)
 
 	rtnl_lock();
 	sit_destroy_tunnels();
-	unregister_netdevice(ipip6_fb_tunnel_dev);
 	rtnl_unlock();
 
 	unregister_pernet_gen_device(sit_net_id, &sit_net_ops);
@@ -1143,32 +1161,11 @@ static int __init sit_init(void)
 		return -EAGAIN;
 	}
 
-	ipip6_fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel), "sit0",
-					   ipip6_tunnel_setup);
-	if (!ipip6_fb_tunnel_dev) {
-		err = -ENOMEM;
-		goto err1;
-	}
-
-	ipip6_fb_tunnel_dev->init = ipip6_fb_tunnel_init;
-
-	if ((err =  register_netdev(ipip6_fb_tunnel_dev)))
-		goto err2;
-
 	err = register_pernet_gen_device(&sit_net_id, &sit_net_ops);
 	if (err < 0)
-		goto err3;
+		xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
 
- out:
 	return err;
- err2:
-	free_netdev(ipip6_fb_tunnel_dev);
- err1:
-	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
-	goto out;
-err3:
-	unregister_netdevice(ipip6_fb_tunnel_dev);
-	goto err1;
 }
 
 module_init(sit_init);
-- 
1.5.3.4

