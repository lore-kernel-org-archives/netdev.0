From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 1/8][IPIP]: Introduce empty ipip_net structure
 and net init/exit ops.
Date: Tue, 15 Apr 2008 16:26:16 +0400
Message-ID: <48049EE8.8090606@openvz.org>
References: <48049E9C.1020207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44364 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759719AbYDOLv6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 07:51:58 -0400
In-Reply-To: <48049E9C.1020207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ipip.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 894bce9..e39a4c2 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -115,10 +115,16 @@
 #include <net/ipip.h>
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
 
 #define HASH_SIZE  16
 #define HASH(addr) (((__force u32)addr^((__force u32)addr>>4))&0xF)
 
+static int ipip_net_id;
+struct ipip_net {
+};
+
 static int ipip_fb_tunnel_init(struct net_device *dev);
 static int ipip_tunnel_init(struct net_device *dev);
 static void ipip_tunnel_setup(struct net_device *dev);
@@ -867,6 +873,41 @@ static struct xfrm_tunnel ipip_handler = {
 static char banner[] __initdata =
 	KERN_INFO "IPv4 over IPv4 tunneling driver\n";
 
+static int ipip_init_net(struct net *net)
+{
+	int err;
+	struct ipip_net *ipn;
+
+	err = -ENOMEM;
+	ipn = kmalloc(sizeof(struct ipip_net), GFP_KERNEL);
+	if (ipn == NULL)
+		goto err_alloc;
+
+	err = net_assign_generic(net, ipip_net_id, ipn);
+	if (err < 0)
+		goto err_assign;
+
+	return 0;
+
+err_assign:
+	kfree(ipn);
+err_alloc:
+	return err;
+}
+
+static void ipip_exit_net(struct net *net)
+{
+	struct ipip_net *ipn;
+
+	ipn = net_generic(net, ipip_net_id);
+	kfree(ipn);
+}
+
+static struct pernet_operations ipip_net_ops = {
+	.init = ipip_init_net,
+	.exit = ipip_exit_net,
+};
+
 static int __init ipip_init(void)
 {
 	int err;
@@ -890,6 +931,10 @@ static int __init ipip_init(void)
 
 	if ((err = register_netdev(ipip_fb_tunnel_dev)))
 		goto err2;
+
+	err = register_pernet_gen_device(&ipip_net_id, &ipip_net_ops);
+	if (err)
+		goto err3;
  out:
 	return err;
  err2:
@@ -897,6 +942,9 @@ static int __init ipip_init(void)
  err1:
 	xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
 	goto out;
+err3:
+	unregister_netdevice(ipip_fb_tunnel_dev);
+	goto err1;
 }
 
 static void __exit ipip_destroy_tunnels(void)
@@ -922,6 +970,8 @@ static void __exit ipip_fini(void)
 	ipip_destroy_tunnels();
 	unregister_netdevice(ipip_fb_tunnel_dev);
 	rtnl_unlock();
+
+	unregister_pernet_gen_device(ipip_net_id, &ipip_net_ops);
 }
 
 module_init(ipip_init);
-- 
1.5.3.4

