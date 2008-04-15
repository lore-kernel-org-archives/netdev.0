From: Pavel Emelyanov <xemul@sw.ru>
Subject: [PATCH net-2.6.26 1/8][GRE]: Introduce empty ipgre_net structure
 and net init/exit ops.
Date: Tue, 15 Apr 2008 16:46:47 +0400
Message-ID: <4804A3B7.8090303@sw.ru>
References: <4804A374.9040505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:11417 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022AbYDOMMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:12:35 -0400
In-Reply-To: <4804A374.9040505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ip_gre.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 50972b3..d729ca8 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -39,6 +39,8 @@
 #include <net/dsfield.h>
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
 
 #ifdef CONFIG_IPV6
 #include <net/ipv6.h>
@@ -122,6 +124,10 @@ static void ipgre_tunnel_setup(struct net_device *dev);
 
 static int ipgre_fb_tunnel_init(struct net_device *dev);
 
+static int ipgre_net_id;
+struct ipgre_net {
+};
+
 static struct net_device *ipgre_fb_tunnel_dev;
 
 /* Tunnel hash table */
@@ -1275,6 +1281,40 @@ static struct net_protocol ipgre_protocol = {
 	.err_handler	=	ipgre_err,
 };
 
+static int ipgre_init_net(struct net *net)
+{
+	int err;
+	struct ipgre_net *ign;
+
+	err = -ENOMEM;
+	ign = kmalloc(sizeof(struct ipgre_net), GFP_KERNEL);
+	if (ign == NULL)
+		goto err_alloc;
+
+	err = net_assign_generic(net, ipgre_net_id, ign);
+	if (err < 0)
+		goto err_assign;
+
+	return 0;
+
+err_assign:
+	kfree(ign);
+err_alloc:
+	return err;
+}
+
+static void ipgre_exit_net(struct net *net)
+{
+	struct ipgre_net *ign;
+
+	ign = net_generic(net, ipgre_net_id);
+	kfree(ign);
+}
+
+static struct pernet_operations ipgre_net_ops = {
+	.init = ipgre_init_net,
+	.exit = ipgre_exit_net,
+};
 
 /*
  *	And now the modules code and kernel interface.
@@ -1302,6 +1342,10 @@ static int __init ipgre_init(void)
 
 	if ((err = register_netdev(ipgre_fb_tunnel_dev)))
 		goto err2;
+
+	err = register_pernet_gen_device(&ipgre_net_id, &ipgre_net_ops);
+	if (err < 0)
+		goto err3;
 out:
 	return err;
 err2:
@@ -1309,6 +1353,9 @@ err2:
 err1:
 	inet_del_protocol(&ipgre_protocol, IPPROTO_GRE);
 	goto out;
+err3:
+	unregister_netdevice(ipgre_fb_tunnel_dev);
+	goto err1;
 }
 
 static void __exit ipgre_destroy_tunnels(void)
@@ -1333,6 +1380,8 @@ static void __exit ipgre_fini(void)
 	rtnl_lock();
 	ipgre_destroy_tunnels();
 	rtnl_unlock();
+
+	unregister_pernet_gen_device(ipgre_net_id, &ipgre_net_ops);
 }
 
 module_init(ipgre_init);
-- 
1.5.3.4

