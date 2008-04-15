From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 1/8][SIT]: Introduce empty struct sit_net and init/exit
 net ops.
Date: Tue, 15 Apr 2008 17:27:49 +0400
Message-ID: <4804AD55.4090605@openvz.org>
References: <4804ACFA.1040003@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44886 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751636AbYDOMxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:53:32 -0400
In-Reply-To: <4804ACFA.1040003@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/sit.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 91e46fb..aa6efc2 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -52,6 +52,8 @@
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
 #include <net/dsfield.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
 
 /*
    This version of net/ipv6/sit.c is cloned of net/ipv4/ip_gre.c
@@ -66,6 +68,10 @@ static int ipip6_fb_tunnel_init(struct net_device *dev);
 static int ipip6_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_setup(struct net_device *dev);
 
+static int sit_net_id;
+struct sit_net {
+};
+
 static struct net_device *ipip6_fb_tunnel_dev;
 
 static struct ip_tunnel *tunnels_r_l[HASH_SIZE];
@@ -1068,6 +1074,41 @@ static void __exit sit_destroy_tunnels(void)
 	}
 }
 
+static int sit_init_net(struct net *net)
+{
+	int err;
+	struct sit_net *sitn;
+
+	err = -ENOMEM;
+	sitn = kmalloc(sizeof(struct sit_net), GFP_KERNEL);
+	if (sitn == NULL)
+		goto err_alloc;
+
+	err = net_assign_generic(net, sit_net_id, sitn);
+	if (err < 0)
+		goto err_assign;
+
+	return 0;
+
+err_assign:
+	kfree(sitn);
+err_alloc:
+	return err;
+}
+
+static void sit_exit_net(struct net *net)
+{
+	struct sit_net *sitn;
+
+	sitn = net_generic(net, sit_net_id);
+	kfree(sitn);
+}
+
+static struct pernet_operations sit_net_ops = {
+	.init = sit_init_net,
+	.exit = sit_exit_net,
+};
+
 static void __exit sit_cleanup(void)
 {
 	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
@@ -1076,6 +1117,8 @@ static void __exit sit_cleanup(void)
 	sit_destroy_tunnels();
 	unregister_netdevice(ipip6_fb_tunnel_dev);
 	rtnl_unlock();
+
+	unregister_pernet_gen_device(sit_net_id, &sit_net_ops);
 }
 
 static int __init sit_init(void)
@@ -1101,6 +1144,10 @@ static int __init sit_init(void)
 	if ((err =  register_netdev(ipip6_fb_tunnel_dev)))
 		goto err2;
 
+	err = register_pernet_gen_device(&sit_net_id, &sit_net_ops);
+	if (err < 0)
+		goto err3;
+
  out:
 	return err;
  err2:
@@ -1108,6 +1155,9 @@ static int __init sit_init(void)
  err1:
 	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
 	goto out;
+err3:
+	unregister_netdevice(ipip6_fb_tunnel_dev);
+	goto err1;
 }
 
 module_init(sit_init);
-- 
1.5.3.4

