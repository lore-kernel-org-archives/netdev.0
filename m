From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 1/7][IP6TUNNEL]: Introduce empty ip6_tnl_net structure
 and net ops.
Date: Tue, 15 Apr 2008 17:59:21 +0400
Message-ID: <4804B4B9.10604@openvz.org>
References: <4804B478.3040606@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53615 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757126AbYDONZC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 09:25:02 -0400
In-Reply-To: <4804B478.3040606@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/ip6_tunnel.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 61517fe..2365eb0 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -52,6 +52,8 @@
 #include <net/xfrm.h>
 #include <net/dsfield.h>
 #include <net/inet_ecn.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
 
 MODULE_AUTHOR("Ville Nuorvala");
 MODULE_DESCRIPTION("IPv6 tunneling device");
@@ -78,6 +80,10 @@ static int ip6_fb_tnl_dev_init(struct net_device *dev);
 static int ip6_tnl_dev_init(struct net_device *dev);
 static void ip6_tnl_dev_setup(struct net_device *dev);
 
+static int ip6_tnl_net_id;
+struct ip6_tnl_net {
+};
+
 /* the IPv6 tunnel fallback device */
 static struct net_device *ip6_fb_tnl_dev;
 
@@ -1384,6 +1390,41 @@ static struct xfrm6_tunnel ip6ip6_handler = {
 	.priority	=	1,
 };
 
+static int ip6_tnl_init_net(struct net *net)
+{
+	int err;
+	struct ip6_tnl_net *ip6n;
+
+	err = -ENOMEM;
+	ip6n = kmalloc(sizeof(struct ip6_tnl_net), GFP_KERNEL);
+	if (ip6n == NULL)
+		goto err_alloc;
+
+	err = net_assign_generic(net, ip6_tnl_net_id, ip6n);
+	if (err < 0)
+		goto err_assign;
+
+	return 0;
+
+err_assign:
+	kfree(ip6n);
+err_alloc:
+	return err;
+}
+
+static void ip6_tnl_exit_net(struct net *net)
+{
+	struct ip6_tnl_net *ip6n;
+
+	ip6n = net_generic(net, ip6_tnl_net_id);
+	kfree(ip6n);
+}
+
+static struct pernet_operations ip6_tnl_net_ops = {
+	.init = ip6_tnl_init_net,
+	.exit = ip6_tnl_exit_net,
+};
+
 /**
  * ip6_tunnel_init - register protocol and reserve needed resources
  *
@@ -1418,7 +1459,13 @@ static int __init ip6_tunnel_init(void)
 		free_netdev(ip6_fb_tnl_dev);
 		goto fail;
 	}
+
+	err = register_pernet_gen_device(&ip6_tnl_net_id, &ip6_tnl_net_ops);
+	if (err < 0)
+		goto err_pernet;
 	return 0;
+err_pernet:
+	unregister_netdevice(ip6_fb_tnl_dev);
 fail:
 	xfrm6_tunnel_deregister(&ip6ip6_handler, AF_INET6);
 unreg_ip4ip6:
@@ -1456,6 +1503,8 @@ static void __exit ip6_tunnel_cleanup(void)
 	rtnl_lock();
 	ip6_tnl_destroy_tunnels();
 	rtnl_unlock();
+
+	unregister_pernet_gen_device(ip6_tnl_net_id, &ip6_tnl_net_ops);
 }
 
 module_init(ip6_tunnel_init);
-- 
1.5.3.4

